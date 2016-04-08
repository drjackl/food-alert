//
//  Spot.m
//  FoodAlert
//
//  Created by Jack Li on 3/18/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "Spot.h"
#import <MapKit/MapKit.h>
#import "Categorie.h"
#import "DataSource.h"

@implementation Spot

- (instancetype) initWithCoordinates:(CLLocationCoordinate2D)coordinate title:(NSString*)title addressDictionary:(NSDictionary*)addressDictionary phone:(NSString*)phone url:(NSURL*)url {
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _title = title;
        
        _addressDictionary = addressDictionary;
        _phone = phone;
        _url = url;
        
        self.savedSpotIndex = -1;
        
        self.saved = NO;
        
        self.notes = @"";
    }
    return self;
}

// thought of setting Spot/Category link in setCategory setter, but you don't want to archive anything when setting category in initWithCoder, so this method is DataSource's setCategory:forSpot:

- (NSString*) formattedAddressWithSeparator:(NSString*)separator {
    NSMutableString* formattedString = [NSMutableString string];
    NSArray* addressLines = self.addressDictionary[@"FormattedAddressLines"];
    NSString* addressString = [addressLines componentsJoinedByString:separator];
    [formattedString appendString:addressString];
    return formattedString;
}


#pragma mark - NSCoding

- (instancetype) initWithCoder:(NSCoder*)aDecoder {
    self = [super init];
    //self = [super initWithCoder:aDecoder]; // why doesn't this work?
    if (self) {
        // this should work, but seems like Apple's code still buggy for this
//        NSValue* coordinateValue = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(coordinate))];
//        _coordinate = coordinateValue.MKCoordinateValue;
        CLLocationCoordinate2D coordinateToDecode;
        coordinateToDecode.latitude = [aDecoder decodeDoubleForKey:@"latitude"];
        coordinateToDecode.longitude = [aDecoder decodeDoubleForKey:@"longitude"];
        _coordinate = coordinateToDecode;
        
        _title = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(title))];
        
        _addressDictionary = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(addressDictionary))];
        _phone = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(phone))];
        _url = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(url))];
        
        self.saved = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(saved))];

        // for simple solution, just decoded category strong property normally; since weak now, this gets set when spot added to category
        
        // strong/weak
        self.savedSpotIndex = [aDecoder decodeIntForKey:NSStringFromSelector(@selector(savedSpotIndex))];
        
        self.notes = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(notes))];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)aCoder {
    // this should work, but seems like Apple's code still buggy for this
//    NSValue* coordinateValue = [NSValue valueWithMKCoordinate:self.coordinate];
//    [aCoder encodeObject:coordinateValue forKey:NSStringFromSelector(@selector(coordinate))];
    [aCoder encodeDouble:self.coordinate.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.coordinate.longitude forKey:@"longitude"];
    
    [aCoder encodeObject:self.title forKey:NSStringFromSelector(@selector(title))];
    
    [aCoder encodeObject:self.addressDictionary forKey:NSStringFromSelector(@selector(addressDictionary))];
    [aCoder encodeObject:self.phone forKey:NSStringFromSelector(@selector(phone))];
    [aCoder encodeObject:self.url forKey:NSStringFromSelector(@selector(url))];
    
    [aCoder encodeBool:self.saved forKey:NSStringFromSelector(@selector(saved))];
    
    // for simple solution, encode the category normally. for strong/weak, don't encode since we'll establish this weak link by looking at category's strong link to the spot
    
    // strong/weak
    [aCoder encodeInt:self.savedSpotIndex forKey:NSStringFromSelector(@selector(savedSpotIndex))];
    
    [aCoder encodeObject:self.notes forKey:NSStringFromSelector(@selector(notes))];
}

@end

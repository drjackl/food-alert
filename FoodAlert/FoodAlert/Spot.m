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

// set the spot <--> category relationship here
//- (void) setCategory:(Categorie*)category {
////    // hmm, not removing old category
////    // if there was an old category, remove spot from its spotsArray
////    if (_category) { // don't think i need this check
////        [_category removeSpot:self];
////    }
////    
////    // spot <--> category
////    [category addSpot:self];
////    _category = category;
//    
//    [_category.spotsArray removeObject:self];
//    [category.spotsArray addObject:self];
//    _category = category;
//    
//    // each linking needs to persist (but not on startup encoding ...)
//    [[DataSource sharedInstance] archiveSavedSpots];
//    [[DataSource sharedInstance] archiveCategories];
//}

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
        
        // needed for strong property
        self.category = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(category))];
        
        self.notes = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(notes))];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)aCoder {
//    NSValue* coordinateValue = [NSValue valueWithMKCoordinate:self.coordinate];
//    [aCoder encodeObject:coordinateValue forKey:NSStringFromSelector(@selector(coordinate))];
    [aCoder encodeDouble:self.coordinate.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.coordinate.longitude forKey:@"longitude"];
    
    [aCoder encodeObject:self.title forKey:NSStringFromSelector(@selector(title))];
    
    [aCoder encodeObject:self.addressDictionary forKey:NSStringFromSelector(@selector(addressDictionary))];
    [aCoder encodeObject:self.phone forKey:NSStringFromSelector(@selector(phone))];
    [aCoder encodeObject:self.url forKey:NSStringFromSelector(@selector(url))];
    
    [aCoder encodeBool:self.saved forKey:NSStringFromSelector(@selector(saved))];
    
    // needed if cat a strong property
    [aCoder encodeObject:self.category forKey:NSStringFromSelector(@selector(category))];
    
    [aCoder encodeObject:self.notes forKey:NSStringFromSelector(@selector(notes))];
}

@end

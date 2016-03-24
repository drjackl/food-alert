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

@implementation Spot

- (instancetype) initWithCoordinates:(CLLocationCoordinate2D)coordinate title:(NSString*)title subtitle:(NSString*)subtitle {
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _title = title;
        _subtitle = subtitle;
        
        self.saved = NO;
    }
    return self;
}

- (void)setCategory:(Categorie*)category {
    _category = category;
    [category addSavedSpot:self];
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
        _subtitle = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(subtitle))];
        
        self.saved = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(saved))];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)aCoder {
//    NSValue* coordinateValue = [NSValue valueWithMKCoordinate:self.coordinate];
//    [aCoder encodeObject:coordinateValue forKey:NSStringFromSelector(@selector(coordinate))];
    [aCoder encodeDouble:self.coordinate.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.coordinate.longitude forKey:@"longitude"];
    
    [aCoder encodeObject:self.title forKey:NSStringFromSelector(@selector(title))];
    [aCoder encodeObject:self.subtitle forKey:NSStringFromSelector(@selector(subtitle))];
    
    [aCoder encodeBool:self.saved forKey:NSStringFromSelector(@selector(saved))];
}

@end

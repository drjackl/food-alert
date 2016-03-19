//
//  Spot.m
//  FoodAlert
//
//  Created by Jack Li on 3/18/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "Spot.h"
#import <MapKit/MapKit.h>

@implementation Spot

- (instancetype) initWithCoordinates:(CLLocationCoordinate2D)coordinate title:(NSString*)title {
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _title = title;
        
        self.saved = NO;
    }
    return self;
}

// NSCoding
- (instancetype) initWithCoder:(NSCoder*)aDecoder {
    self = [super init];
    if (self) {
//        NSValue* coordinateValue = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(coordinate))];
//        _coordinate = coordinateValue.MKCoordinateValue;
        CLLocationCoordinate2D coordinateToDecode;
        coordinateToDecode.latitude = [aDecoder decodeDoubleForKey:@"latitude"];
        coordinateToDecode.longitude = [aDecoder decodeDoubleForKey:@"longitude"];
        _coordinate = coordinateToDecode;
        
        _title = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(title))];
        
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
    
    [aCoder encodeBool:self.saved forKey:NSStringFromSelector(@selector(saved))];
}

@end

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

- (instancetype) initWithTitle:(NSString*)title coordinates:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self) {
        _title = title;
        _coordinate = coordinate;
    }
    return self;
}

@end

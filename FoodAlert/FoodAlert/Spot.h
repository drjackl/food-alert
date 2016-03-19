//
//  Spot.h
//  FoodAlert
//
//  Created by Jack Li on 3/18/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Spot : NSObject <MKAnnotation, NSCoding>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate; // MKAnnotation required, KVC
@property (nonatomic, readonly, copy) NSString* title; // MKAnnotation

@property (nonatomic) BOOL saved;

- (instancetype) initWithCoordinates:(CLLocationCoordinate2D)coordinate title:(NSString*)title;

@end

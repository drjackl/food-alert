//
//  Spot.h
//  FoodAlert
//
//  Created by Jack Li on 3/18/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
//#import "Categorie.h" // circular import bad

@class Categorie;

@interface Spot : NSObject <MKAnnotation, NSCoding>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate; // MKAnnotation required, KVC
@property (nonatomic, readonly, copy) NSString* title; // MKAnnotation
@property (nonatomic, readonly, copy) NSString* subtitle; // MKAnnotation

@property (nonatomic) BOOL saved;

@property (nonatomic) Categorie* category; // Spot -strong-> Cat -weak-> SpotArray -strong-> Spot

- (instancetype) initWithCoordinates:(CLLocationCoordinate2D)coordinate title:(NSString*)title subtitle:(NSString*)subtitle;

@end

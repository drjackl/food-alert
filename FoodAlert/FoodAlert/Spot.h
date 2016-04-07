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
//@property (nonatomic, readonly, copy) NSString* subtitle; // MKAnnotation
@property (nonatomic, readonly, copy) NSDictionary* addressDictionary;
@property (nonatomic, readonly, copy) NSString* phone;
@property (nonatomic, readonly, copy) NSURL* url;

@property (nonatomic) BOOL saved;

@property (weak, nonatomic) Categorie* category; // Category owns array of Spots, so weak link back
@property (nonatomic) short savedSpotIndex;

@property (nonatomic) NSString* notes;

- (instancetype) initWithCoordinates:(CLLocationCoordinate2D)coordinate title:(NSString*)title addressDictionary:(NSDictionary*)addressDictionary phone:(NSString*)phone url:(NSURL*)url;

- (NSString*) formattedAddressWithSeparator:(NSString*)separator;

@end

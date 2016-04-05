//
//  Category.h
//  FoodAlert
//
//  Created by Jack Li on 3/20/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "Spot.h" // circular import bad

@class Spot;

@interface Categorie : NSObject <NSCoding>

@property (nonatomic) NSString* title;
@property (nonatomic) UIColor* color;

//@property (readonly, nonatomic) NSMutableArray* spotsArray; // Cat -strong-> SpotArray -strong-> Spot -weak-> Cat

- (instancetype) initWithColor:(UIColor*)color;
- (instancetype) initWithTitle:(NSString*)title color:(UIColor*)color;

// should only be called by Spot's setCategory method to maintain strong/weak cyclical reference
//- (void) addSpot:(Spot*)spot;
//- (void) removeSpot:(Spot*)sSpot;
//- (void) removeAllSpots; // called when category being removed

@end

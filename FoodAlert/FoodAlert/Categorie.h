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

@property (nonatomic, weak) NSMutableArray* spotsInCategory; // Cat -weak-> SpotArray -strong-> Spot -strong-> Cat

- (instancetype) initWithColor:(UIColor*)color;
- (instancetype) initWithTitle:(NSString*)title color:(UIColor*)color;

- (void) addSavedSpot:(Spot*)savedSpot;

@end

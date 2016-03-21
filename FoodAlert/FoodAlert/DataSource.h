//
//  DataSource.h
//  FoodAlert
//
//  Created by Jack Li on 3/19/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapViewController.h"
#import "ListTableViewController.h"

@interface DataSource : NSObject

+ (instancetype) sharedInstance;

@property (nonatomic) NSArray* savedSpots;
@property (nonatomic) NSArray* categories;

@property (nonatomic) NSArray* currentSearchedSpots;

@property (nonatomic) MapViewController* mapVC; // until get KVO in
@property (nonatomic) ListTableViewController* listVC;

// both should be taken out after KVO
- (void) archiveSavedSpots;
- (void) unarchiveSavedSpots;

@end

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
#import "Categorie.h"

@interface DataSource : NSObject

+ (instancetype) sharedInstance;

@property (nonatomic) NSMutableArray* savedSpots;
@property (nonatomic) NSArray* categories;

@property (nonatomic) NSArray* savedSpotsBeingShown;
@property (nonatomic) NSArray* currentSearchedSpots;

@property (nonatomic) MapViewController* mapVC; // until get KVO in
@property (nonatomic) ListTableViewController* listVC;

- (void) filterSavedSpotsWithCategory:(Categorie*)category;

// both should be taken out after KVO? (save on any change to savedSpots?)
- (void) archiveSavedSpots;
- (void) unarchiveSavedSpots;

- (void) archiveCategories;

@end

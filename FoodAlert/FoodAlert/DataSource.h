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

@property (readonly, nonatomic) NSMutableArray* savedSpots;
@property (readonly, nonatomic) NSMutableArray* categories;

@property (readonly, nonatomic) NSMutableArray* unusedColors;

@property (readonly, nonatomic) NSArray* savedSpotsBeingShown;
@property (readonly, nonatomic) NSArray* savedSpotsByDistance;

@property (nonatomic) NSArray* currentSearchedSpots;

- (void) filterSavedSpotsWithCategory:(Categorie*)category alwaysRefresh:(BOOL)alwaysRefresh;

- (NSArray*) sortSavedSpots:(CLLocation*)currentLocation;

// Persisting Data
- (void) saveSpot:(Spot*)spot;
- (void) deleteSpot:(Spot*)spot;
- (void) addCategoryWithName:(NSString*)name fromColorAtIndex:(int)i; // calls archiveUnusedCategories
- (void) deleteCategoryAtIndex:(int)i;

- (void) archiveSavedSpots;
- (void) archiveCategories;

@end

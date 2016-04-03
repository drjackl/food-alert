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
@property (nonatomic) NSMutableArray* categories;
@property (nonatomic) NSMutableArray* unusedColors;

@property (nonatomic) NSArray* savedSpotsBeingShown;
@property (nonatomic) NSArray* savedSpotsByDistance;
@property (nonatomic) NSArray* currentSearchedSpots;

- (void) filterSavedSpotsWithCategory:(Categorie*)category alwaysRefresh:(BOOL)alwaysRefresh;

- (NSArray*) sortSavedSpots:(CLLocation*)currentLocation;

// Persisting Data
- (void) saveSpot:(Spot*)spot;
- (void) addCategoryWithName:(NSString*)name fromColorAtIndex:(int)i; // calls archiveUnusedCategories
- (void) archiveSavedSpots;
- (void) archiveCategories;

@end

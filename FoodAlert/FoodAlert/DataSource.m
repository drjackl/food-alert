//
//  DataSource.m
//  FoodAlert
//
//  Created by Jack Li on 3/19/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "DataSource.h"
#import "Spot.h"


@interface DataSource ()
@property (nonatomic) NSMutableArray* savedSpots;
@property (nonatomic) NSMutableArray* categories;

@property (nonatomic) NSMutableArray* unusedColors;

@property (nonatomic) NSArray* savedSpotsBeingShown;
@property (nonatomic) NSArray* savedSpotsByDistance;

//@property (nonatomic) NSArray* currentSearchedSpots; // putting as readwrite in .h so searchVC can access

@property (nonatomic) Categorie* filterCategory;
@end

//// could declare function here too
//NSInteger distanceSort (id spot1, id spot2, void* context) {
//    return 0;
//}

@implementation DataSource

+ (instancetype) sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        self.savedSpots = [NSMutableArray array];
        self.categories = [NSMutableArray array];
        self.unusedColors = [NSMutableArray array];
        
        self.currentSearchedSpots = [NSArray array];
        self.savedSpotsBeingShown = [NSArray array];
        self.savedSpotsByDistance = [NSArray array];
                
        [self unarchiveSavedSpots];
        [self unarchiveCategories];
        [self unarchiveUnusedColors];
    }
    return self;
}

#pragma mark - Category Filtering

- (void) filterSavedSpotsWithCategory:(Categorie*)category alwaysRefresh:(BOOL)alwaysRefresh {
    // if alwaysRefresh, always filter; else only filter if different from current filter category
    if (alwaysRefresh ||
        self.filterCategory != category) {
        
        self.filterCategory = category;
        
        if (category) {
            NSArray* filteredArray = [self.savedSpots filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"category = %@", category]];
            self.savedSpotsBeingShown = filteredArray;
        } else {
            self.savedSpotsBeingShown = [self.savedSpots copy]; // always want a different object to trigger refreshing
        }
    }
    
    //self.savedSpotsBeingShown = category.spotsInCategory ? category.spotsInCategory : [NSArray new]; // using Cat property of spots (vs. filtering each time)
}

- (void) refreshSavedSpotsBeingShown {
    [self filterSavedSpotsWithCategory:self.filterCategory alwaysRefresh:YES];
}

#pragma mark - Nearby Notifications

//- (NSInteger) distanceSort (id spot1, id spot2, void* context) {
//    return 0;
//}

NSInteger distanceSort (id spot1, id spot2, void* context) {
    CLLocation* currentLocation = (__bridge CLLocation*)context;

    CLLocationCoordinate2D coordinate1 = ((Spot*)spot1).coordinate;
    CLLocationCoordinate2D coordinate2 = ((Spot*)spot2).coordinate;
    CLLocation* location1 = [[CLLocation alloc] initWithLatitude:coordinate1.latitude longitude:coordinate1.longitude];
    CLLocation* location2 = [[CLLocation alloc] initWithLatitude:coordinate2.latitude longitude:coordinate2.longitude];
    CLLocationDistance distance1 = [location1 distanceFromLocation:currentLocation];
    CLLocationDistance distance2 = [location2 distanceFromLocation:currentLocation];
    
    if (distance1 < distance2) {
        return NSOrderedAscending;
    } else if (distance1 > distance2) {
        return NSOrderedDescending;
    } else { // d1 == d2
        return NSOrderedSame;
    }
}

- (NSArray*) sortSavedSpots:(CLLocation*)currentLocation {
    self.savedSpotsByDistance = [self.savedSpots sortedArrayUsingFunction:distanceSort context:(__bridge void*_Nullable)(currentLocation)];
    return self.savedSpotsByDistance;
}


#pragma mark - Persisting data (Public)

- (void) saveSpot:(Spot*)spot {
    Spot* spotCopy = [[Spot alloc] initWithCoordinates:spot.coordinate title:spot.title addressDictionary:spot.addressDictionary phone:spot.phone url:spot.url];
    spotCopy.saved = YES;
    
    // necessary for KVO (doesn't get triggered if [self.savedSpots addObject])
    NSMutableArray* mutableArrayWithKVO = [self mutableArrayValueForKey:NSStringFromSelector(@selector(savedSpots))];
    [mutableArrayWithKVO addObject:spotCopy];
    
    // refresh savedSpots (could just add or not based on if it's in current category)
    [self refreshSavedSpotsBeingShown];
    
    [self archiveSavedSpots];
}

- (void) deleteSpot:(Spot*)spot {
    NSMutableArray* mutableArrayWithKVO = [self mutableArrayValueForKey:NSStringFromSelector(@selector(savedSpots))];
    [mutableArrayWithKVO removeObject:spot];
    
    // use this to make disappear
    [self refreshSavedSpotsBeingShown];
    
    [self archiveSavedSpots];
}

- (void) addCategoryWithName:(NSString*)name fromColorAtIndex:(int)i {
    UIColor* color = self.unusedColors[i];
    [self.unusedColors removeObjectAtIndex:i];
    
    Categorie* category = [[Categorie alloc] initWithTitle:name color:color];
    NSMutableArray* mutableArrayWithKVO = [self mutableArrayValueForKey:NSStringFromSelector(@selector(categories))];
    [mutableArrayWithKVO addObject:category];
    //[self.categories addObject:category]; // need to trigger KVO since not a wholesale replacement
    
    [self archiveCategories];
    [self archiveUnusedColors];
}

- (void) deleteCategoryAtIndex:(int)i {
    Categorie* category = self.categories[i];
    UIColor* colorToRecycle = category.color;
    
    NSMutableArray* mutableArrayWithKVO = [self mutableArrayValueForKey:NSStringFromSelector(@selector(categories))];
    [mutableArrayWithKVO removeObjectAtIndex:i];
    
    // recycle the color back to unusedColors array
    [self.unusedColors addObject:colorToRecycle];
    
    [self archiveCategories];
    [self archiveUnusedColors];
}

- (void) archiveSavedSpots {
    [self archiveObject:self.savedSpots withFilename:NSStringFromSelector(@selector(savedSpots))];
}

- (void) archiveCategories {
    [self archiveObject:self.categories withFilename:NSStringFromSelector(@selector(categories))];
}


#pragma mark - Persisting data (Private)

- (void) archiveUnusedColors {
    [self archiveObject:self.unusedColors withFilename:NSStringFromSelector(@selector(unusedColors))];
}

- (void) archiveObject:(NSObject*)object withFilename:(NSString*)filename {
    // based off blocstagram
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* fullPath = [self pathForFilename:filename];
        NSData* objectsToStore = [NSKeyedArchiver archivedDataWithRootObject:object];
        NSError* dataError;
        
        BOOL wroteSuccessfully = [objectsToStore writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
        
        if (!wroteSuccessfully) {
            NSLog(@"Couldn't write file: %@", dataError);
        }
    });
}

- (NSString*) pathForSavedSpots {
    return [self pathForFilename:NSStringFromSelector(@selector(savedSpots))];
}

- (NSString*) pathForCategories {
    return [self pathForFilename:NSStringFromSelector(@selector(categories))];
}

- (NSString*) pathForFilename:(NSString*)filename {
    // use TemporaryDirectory instead?
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* directory = [paths firstObject];
    NSString* dataPath = [directory stringByAppendingPathComponent:filename];
    return dataPath;
}

- (void) unarchiveSavedSpots {
    // dispatch to background since unarchiving might be slow
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* fullPath = [self pathForSavedSpots];
        
        NSArray* savedSpotsToLoad = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
        
        // once unarchived, dispatch back to main to set savedSpots to what we unarchived
        dispatch_async(dispatch_get_main_queue(), ^{
            if (savedSpotsToLoad.count > 0) { // if don't check, savedSpots set back to nil
                NSMutableArray* mutableSavedSpots = [savedSpotsToLoad mutableCopy];
                self.savedSpots = mutableSavedSpots;
                
                // set visible spots after unarchiving
                self.savedSpotsBeingShown = self.savedSpots;
                
                // was adding spots directly to map and list VC before KVO
            }
        });
    });
}


- (void) unarchiveCategories {
    // dispatch to background since unarchiving might be slow
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* fullPath = [self pathForCategories];
        
        NSArray* categoriesToLoad = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
        
        // once unarchived, dispatch back to main to set savedSpots to what we unarchived
        dispatch_async(dispatch_get_main_queue(), ^{
            if (categoriesToLoad.count > 0) {
                NSMutableArray* mutableCategories = [categoriesToLoad mutableCopy];
                self.categories = mutableCategories;
            } else { // first time running app, load default categories and unused colors
                self.categories = [[self defaultCategories] mutableCopy];
                [self archiveCategories];
                self.unusedColors = [[self defaultUnusedColors] mutableCopy];
                [self archiveUnusedColors];
            }
            
            // update any views that would be done in KVO (don't think I need to)
        });
    });
}

- (void) unarchiveUnusedColors {
    // dispatch to background since unarchiving might be slow
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* fullPath = [self pathForFilename:NSStringFromSelector(@selector(unusedColors))];
        
        NSArray* categoryColorsToLoad = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
        
        // once unarchived, dispatch back to main to set savedSpots to what we unarchived
        dispatch_async(dispatch_get_main_queue(), ^{
            if (categoryColorsToLoad.count > 0) {
                NSMutableArray* mutableCategoryColors = [categoryColorsToLoad mutableCopy];
                self.unusedColors = mutableCategoryColors;
            }
            
            // if no colors, it could be first time, or all colors could've been used up
        });
    });
}

- (NSArray*) defaultCategories {
    return @[[[Categorie alloc] initWithTitle:@"Check out later" color:[UIColor magentaColor]],
             [[Categorie alloc] initWithTitle:@"Restaurants" color:[UIColor greenColor]]];
}

- (NSArray*) defaultUnusedColors {
    return @[[UIColor orangeColor],
             [UIColor cyanColor],
             [UIColor redColor],
             [UIColor brownColor],
             [UIColor purpleColor],
             [UIColor grayColor],
             [UIColor yellowColor]];
}

@end

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

@property (nonatomic) Categorie* filterCategory;
@end


// could declare function here too


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
        
        // strong/weak solution
        [self unarchiveCategoriesAndSavedSpots];
        
        [self unarchiveUnusedColors]; // works for both simple and strong/weak
    }
    return self;
}


#pragma mark - Category Filtering

- (void) filterSavedSpotsWithCategory:(Categorie*)category alwaysRefresh:(BOOL)alwaysRefresh {
    // if alwaysRefresh, always filter; else only filter if different from current filter category
    if (alwaysRefresh ||
        self.filterCategory != category) {
        
        self.filterCategory = category;
        
        if (category) { // (could be reduced to a ternary)
            // strong/weak uses Cat's spots property, whereas simple solution had to filter for Cat
            self.savedSpotsBeingShown = [category.spotsArray copy];
        } else {
            self.savedSpotsBeingShown = [self.savedSpots copy]; // always want a different object to trigger refreshing
        }
    }
}

- (void) refreshSavedSpotsBeingShown {
    [self filterSavedSpotsWithCategory:self.filterCategory alwaysRefresh:YES];
}

#pragma mark - Nearby Notifications

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

// returns the sorted savedSpots but also sets the savedSpotsByDistance property
- (NSArray*) sortSavedSpots:(CLLocation*)currentLocation {
    self.savedSpotsByDistance = [self.savedSpots sortedArrayUsingFunction:distanceSort context:(__bridge void*_Nullable)(currentLocation)];
    return self.savedSpotsByDistance;
}

#pragma mark - Linking a Spot to its Category

// link by adding spot to category and set weak property too. before linking, unlink the previous category by removing the spot from the previous category. if before (and/or after) category nil, won't remove (and/or add), just set spot category to nil
- (void) setCategory:(Categorie*)category forSpot:(Spot*)spot {
    [spot.category.spotsArray removeObject:spot];
    [category.spotsArray addObject:spot];
    spot.category = category;
    
    [[DataSource sharedInstance] archiveSavedSpots];
    
    // technically, if both the previous and setting category are nil, no need to archive categories
    [[DataSource sharedInstance] archiveCategories];
}


#pragma mark - Persisting data (Public)

- (void) saveSpot:(Spot*)spot {
    Spot* spotCopy = [[Spot alloc] initWithCoordinates:spot.coordinate title:spot.title addressDictionary:spot.addressDictionary phone:spot.phone url:spot.url];
    spotCopy.saved = YES;

    // for strong/weak, each savedSpot must always have up-to-date savedSpotIndex
    spotCopy.savedSpotIndex = self.savedSpots.count; // index is always the end when adding
    
    // necessary for KVO (doesn't get triggered if [self.savedSpots addObject])
    NSMutableArray* mutableArrayWithKVO = [self mutableArrayValueForKey:NSStringFromSelector(@selector(savedSpots))];
    [mutableArrayWithKVO addObject:spotCopy];
    
    // refresh savedSpots (could just add or not based on if it's in current category)
    [self refreshSavedSpotsBeingShown];
    
    [self archiveSavedSpots];
    

    // this prompts user for notifications permissions (first time should be when region added, but that would be put in a loop, so first time when first save)
    UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
    UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

// Deleting AND Unlinking
- (void) deleteSpot:(Spot*)spot {
    NSInteger indexOfSpotBeingRemoved = [self.savedSpots indexOfObject:spot];
    
    NSMutableArray* mutableArrayWithKVO = [self mutableArrayValueForKey:NSStringFromSelector(@selector(savedSpots))];
    [mutableArrayWithKVO removeObjectAtIndex:indexOfSpotBeingRemoved];
    
    // for strong/weak, update savedSpotIndex for subsequent spots
    for (NSInteger i = indexOfSpotBeingRemoved; i < mutableArrayWithKVO.count; i++) {
        ((Spot*)[mutableArrayWithKVO objectAtIndex:i]).savedSpotIndex = i;
    }
    
    // if deleting spot, must delete from category list too since strong reference
    [[DataSource sharedInstance] setCategory:nil forSpot:spot]; // unlinking (set cat to nil)
    
    // use this to make disappear
    [self refreshSavedSpotsBeingShown];
    
    // for strong/weak, archiving takes place in setCategory:forSpot:
}

// adding a new category also means removing the used color from unusedColors
- (void) addCategoryWithName:(NSString*)name fromColorAtIndex:(int)i {
    UIColor* color = self.unusedColors[i];
    [self.unusedColors removeObjectAtIndex:i];
    
    Categorie* category = [[Categorie alloc] initWithTitle:name color:color];
    NSMutableArray* mutableArrayWithKVO = [self mutableArrayValueForKey:NSStringFromSelector(@selector(categories))];
    [mutableArrayWithKVO addObject:category];
    
    [self archiveCategories];
    [self archiveUnusedColors];
}

- (void) deleteCategoryAtIndex:(NSInteger)i {
    Categorie* category = self.categories[i];
    
    NSMutableArray* mutableArrayWithKVO = [self mutableArrayValueForKey:NSStringFromSelector(@selector(categories))];
    [mutableArrayWithKVO removeObjectAtIndex:i];
    
    // set category property of spots with category to nil (strong/weak uses cat's spotArray, whereas simple solution used filtering)
    [category.spotsArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL*_Nonnull stop) {
        [[DataSource sharedInstance] setCategory:nil forSpot:(Spot*)obj];
    }];

    
    // recycle the color back to unusedColors array
    UIColor* colorToRecycle = category.color;
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


- (void) unarchiveCategoriesAndSavedSpots {
    // dispatch to background since unarchiving might be slow
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 1. unarchive spots
        NSString* fullSavedSpotsPath = [self pathForSavedSpots];
        NSArray* savedSpotsToLoad = [NSKeyedUnarchiver unarchiveObjectWithFile:fullSavedSpotsPath];
        NSMutableArray* mutableSavedSpotsToLoad = [savedSpotsToLoad mutableCopy];
        
        // 2. unarchive categories
        NSString* fullCategoryPath = [self pathForCategories];
        NSArray* categoriesToLoad = [NSKeyedUnarchiver unarchiveObjectWithFile:fullCategoryPath];
        
        // 3. for each category, for each spot, unarchive spot and set in right place of savedSpots
        [categoriesToLoad enumerateObjectsUsingBlock:^(id _Nonnull obj1, NSUInteger idx1, BOOL*_Nonnull stop1) {
            Categorie* category = obj1;
            
            // for each spot in the category
            [category.spotsArray enumerateObjectsUsingBlock:^(id _Nonnull obj2, NSUInteger idx2, BOOL*_Nonnull stop2) {
                Spot* spot = obj2;
                
                // set weak link
                spot.category = category;
                
                // replace in right place of savedSpots (replacing the first unarchived spot)
                [mutableSavedSpotsToLoad replaceObjectAtIndex:spot.savedSpotIndex withObject:spot];
            }];
        }];
        
        // once unarchived, dispatch back to main to set categories and savedSpots to what we unarchived
        dispatch_async(dispatch_get_main_queue(), ^{
            // set categories (and unused colors if first time or no categories)
            if (categoriesToLoad.count > 0) {
                NSMutableArray* mutableCategories = [categoriesToLoad mutableCopy];
                self.categories = mutableCategories;
                // had thought of doing the linking of spots and categories here
            } else { // first time running app, load default categories and unused colors
                self.categories = [[self defaultCategories] mutableCopy];
                [self archiveCategories];
                self.unusedColors = [[self defaultUnusedColors] mutableCopy];
                [self archiveUnusedColors];
            }
            
            // set savedSpots (based off above unarchiveSavedSpots)
            if (mutableSavedSpotsToLoad.count > 0) { // if don't check, savedSpots set back to nil
                // simple solution just made a mutable copy of savedSpots loaded/unkeyed

                // strong/weak: we create savedSpots as unpackaging
                self.savedSpots = mutableSavedSpotsToLoad; //savedSpotsToLoad; // oops
                
                // set visible spots after unarchiving
                self.savedSpotsBeingShown = self.savedSpots;
                
                // was adding spots directly to map and list VC before KVO
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

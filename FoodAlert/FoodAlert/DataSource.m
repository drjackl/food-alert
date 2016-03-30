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
@property (nonatomic) Categorie* filterCategory;
@end

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
        self.categories = [NSArray array];
        
        self.currentSearchedSpots = [NSArray array];
        self.savedSpotsBeingShown = [NSArray array];
                
        [self unarchiveSavedSpots];
        [self unarchiveCategories];
    }
    return self;
}

- (void) filterSavedSpotsWithCategory:(Categorie*)category {
    self.filterCategory = category;
    
    if (category) {
        NSArray* filteredArray = [self.savedSpots filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"category = %@", category]];
        self.savedSpotsBeingShown = filteredArray;
    } else {
        self.savedSpotsBeingShown = self.savedSpots;
    }
    
    //self.savedSpotsBeingShown = category.spotsInCategory ? category.spotsInCategory : [NSArray new];
}

- (void) refreshSavedSpotsBeingShown {
    [self filterSavedSpotsWithCategory:self.filterCategory];
}

#pragma mark - Persisting data

- (void) saveSpot:(Spot*)spot {
    spot.saved = YES;
    [self.savedSpots addObject:spot];
    
    // refresh savedSpots (could just add or not based on if it's in current category)
    [self refreshSavedSpotsBeingShown];
    
    [self archiveSavedSpots];
}

- (void) archiveSavedSpots {
    // based off blocstagram
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* fullPath = [self pathForSavedSpots];
        NSData* savedSpotsToStore = [NSKeyedArchiver archivedDataWithRootObject:self.savedSpots];
        NSError* dataError;
        
        BOOL wroteSuccessfully = [savedSpotsToStore writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
        
        if (!wroteSuccessfully) {
            NSLog(@"Couldn't write file: %@", dataError);
        }
    });
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
                
                // delete when KVO in for savedSpots
                //[self.mapVC addSpots:self.savedSpotsBeingShown]; // table ought to load same time here ...
                //[self.listVC reloadTableView];
            }

        });
    });
}

- (NSString*) pathForSavedSpots {
    return [self pathForFilename:NSStringFromSelector(@selector(savedSpots))];
}

- (void) archiveCategories {
    // based off blocstagram
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* fullPath = [self pathForCategories];
        NSData* categoriesToStore = [NSKeyedArchiver archivedDataWithRootObject:self.categories];
        NSError* dataError;
        
        BOOL wroteSuccessfully = [categoriesToStore writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
        
        if (!wroteSuccessfully) {
            NSLog(@"Couldn't write file: %@", dataError);
        }
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
            } else { // first time running app
                self.categories = [self defaultCategories];
                [self archiveCategories];
            }
            
            // update any views that would be done in KVO (don't think I need to)
        });
    });
}

- (NSArray*) defaultCategories {
    return @[[[Categorie alloc] initWithTitle:@"Check out later" color:[UIColor redColor]],
             [[Categorie alloc] initWithTitle:@"Restaurants" color:[UIColor greenColor]],
             [[Categorie alloc] initWithColor:[UIColor orangeColor]],
             [[Categorie alloc] initWithColor:[UIColor whiteColor]],
             [[Categorie alloc] initWithColor:[UIColor cyanColor]],
             [[Categorie alloc] initWithColor:[UIColor lightGrayColor]],
             [[Categorie alloc] initWithColor:[UIColor brownColor]],
             [[Categorie alloc] initWithColor:[UIColor purpleColor]],
             [[Categorie alloc] initWithColor:[UIColor grayColor]],
             [[Categorie alloc] initWithColor:[UIColor yellowColor]]];
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

@end

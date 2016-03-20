//
//  DataSource.m
//  FoodAlert
//
//  Created by Jack Li on 3/19/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "DataSource.h"

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
        self.currentSearchedSpots = [NSArray array];
        
        [self unarchiveSavedSpots];
    }
    return self;
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* fullPath = [self pathForSavedSpots];
        
        NSArray* savedSpotsToLoad = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
        
        // maybe i don't need this since i'm not downloading blocstagram images?
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray* mutableSavedSpots = [savedSpotsToLoad mutableCopy];
            self.savedSpots = mutableSavedSpots;
            
            // delete when KVO in
            [self.mapVC addSpots:self.savedSpots]; // table ought to load same time here ...
            [self.listVC reloadTableView];
        });
    });
}

- (NSString*) pathForSavedSpots {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString* directory = [paths firstObject];
    NSString* dataPath = [directory stringByAppendingString:NSStringFromSelector(@selector(savedSpots))];
    return dataPath;
}

@end

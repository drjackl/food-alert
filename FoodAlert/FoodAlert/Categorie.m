//
//  Category.m
//  FoodAlert
//
//  Created by Jack Li on 3/20/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "Categorie.h"
// interesting, don't need to import Spot.h, found out this is because I don't use Spot methods
//#import "Spot.h"

@implementation Categorie

- (instancetype) initWithTitle:(NSString*)title color:(UIColor*)color {
    self = [super init];
    if (self) {
        self.title = title;
        self.color = color;
        
        self.spotsInCategory = [NSMutableArray array]; // not needed if weak pointer?
    }
    return self;
}

- (instancetype) initWithColor:(UIColor*)color {
    return [self initWithTitle:@"" color:color];
}

// should only be called by setCategory (or addCategory later maybe)
- (void) addSavedSpot:(Spot*)savedSpot {
    if (!self.spotsInCategory) { // because weak pointer
        self.spotsInCategory = [NSMutableArray array];
    }
    [self.spotsInCategory addObject:savedSpot];
    //[savedSpot setSaved:NO]; // testing import, i need import to use methods
}

#pragma mark - NSCoding

- (instancetype) initWithCoder:(NSCoder*)aDecoder {
    self = [super init];
    //self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(title))];
        self.color = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(color))];
        
        self.spotsInCategory = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(spotsInCategory))];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:self.title forKey:NSStringFromSelector(@selector(title))];
    [aCoder encodeObject:self.color forKey:NSStringFromSelector(@selector(color))];
    
    [aCoder encodeObject:self.spotsInCategory forKey:NSStringFromSelector(@selector(spotsInCategory))];
}

@end

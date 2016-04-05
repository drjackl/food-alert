//
//  Category.m
//  FoodAlert
//
//  Created by Jack Li on 3/20/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "Categorie.h"
// interesting, don't need to import Spot.h, found out this is because I don't use Spot methods
#import "Spot.h" // but now i need it

@implementation Categorie

- (instancetype) initWithTitle:(NSString*)title color:(UIColor*)color {
    self = [super init];
    if (self) {
        self.title = title;
        self.color = color;
        
        _spotsArray = [NSMutableArray array]; // (not needed if weak pointer?)
    }
    return self;
}

- (instancetype) initWithColor:(UIColor*)color {
    return [self initWithTitle:@"" color:color];
}

// for filtering
- (BOOL) isEqual:(id)object {
    if ([object isKindOfClass:[Categorie class]]) {
        Categorie* category = (Categorie*)object;
        return [self.title isEqualToString:category.title] && [self.color isEqual:category.color];
    }
    return NO;
}

// should only be called by Spot's setCategory (or addCategory later maybe); THIS is the link
//- (void) addSpot:(Spot*)spot {
////    if (!self.spotsInCategory) { // because weak pointer
////        self.spotsInCategory = [NSMutableArray array];
////    }
//    
//    // first remove spot from old category
//    [spot.category.spotsArray removeObject:spot];
//    
//    [self.spotsArray addObject:spot]; // category was already set in Spot (not anymore)
//    spot.category = self; // set cycle
//}

// break the spot <--> category relationship
- (void) removeSpot:(Spot*)spot {
    [self.spotsArray removeObject:spot];
    // set spot to nil (i think i meant set the category to nil)
    spot.category = nil; // this causes infinite loop
}

// break the spot <--> category relationship for all category's spots
- (void) removeAllSpots {
    //[self.spotsArray removeAllObjects];
    // maybe set each spot's category to nil now?
    
    [self.spotsArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL*_Nonnull stop) {
        [self removeSpot:obj];
    }];
}

#pragma mark - NSCoding

- (instancetype) initWithCoder:(NSCoder*)aDecoder {
    self = [super init];
    //self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(title))];
        self.color = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(color))];
        
        _spotsArray = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(spotsArray))];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:self.title forKey:NSStringFromSelector(@selector(title))];
    [aCoder encodeObject:self.color forKey:NSStringFromSelector(@selector(color))];
    
    [aCoder encodeObject:self.spotsArray forKey:NSStringFromSelector(@selector(spotsArray))];
}

@end

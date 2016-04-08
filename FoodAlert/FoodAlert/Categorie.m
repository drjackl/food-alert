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
        
        _spotsArray = [NSMutableArray array]; // for strong/weak (not needed for simple)
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


#pragma mark - NSCoding

- (instancetype) initWithCoder:(NSCoder*)aDecoder {
    self = [super init];
    //self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(title))];
        self.color = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(color))];
        
        // interesting: if spotsArray never encoded, it doesn't exist and no run-time error decoding
        _spotsArray = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(spotsArray))];
        //_spotsArray = [NSMutableArray new]; // new array for now just to non-archive features (like saveSpot, deleteSpot, setCat, addCat, deleteCat)
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:self.title forKey:NSStringFromSelector(@selector(title))];
    [aCoder encodeObject:self.color forKey:NSStringFromSelector(@selector(color))];
    
    [aCoder encodeObject:self.spotsArray forKey:NSStringFromSelector(@selector(spotsArray))];
}

@end

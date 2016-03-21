//
//  Category.m
//  FoodAlert
//
//  Created by Jack Li on 3/20/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "Categorie.h"

@implementation Categorie

- (instancetype) initWithTitle:(NSString *)title color:(UIColor*)color {
    self = [super init];
    if (self) {
        self.title = title;
        self.color = color;
    }
    return self;
}

- (instancetype) initWithColor:(UIColor*)color {
    return [self initWithTitle:@"" color:color];
}

#pragma mark - NSCoding

- (instancetype) initWithCoder:(NSCoder*)aDecoder {
    self = [super init];
    //self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(title))];
        self.color = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(color))];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:self.title forKey:NSStringFromSelector(@selector(title))];
    [aCoder encodeObject:self.color forKey:NSStringFromSelector(@selector(color))];
}

@end

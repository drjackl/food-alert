//
//  CategorySelectViewController.h
//  FoodAlert
//
//  Created by Jack Li on 3/24/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Categorie.h"

@protocol CategorySelectViewControllerDelegate <NSObject>
- (void) didSelectCategory:(Categorie*)category;
@end

@interface CategorySelectViewController : UIViewController

@property (weak, nonatomic) id<CategorySelectViewControllerDelegate> delegate;

@property (nonatomic) BOOL isFirstItemNone;

@end

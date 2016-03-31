//
//  CategoryPresentationController.h
//  FoodAlert
//
//  Created by Jack Li on 3/24/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryPresentationController : UIPresentationController

- (instancetype) initWithPresentedViewController:(UIViewController*)presentedViewController presentingViewController:(UIViewController*)presentingViewController pack:(BOOL)pack;

@end

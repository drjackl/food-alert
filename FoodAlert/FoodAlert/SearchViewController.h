//
//  SearchViewController.h
//  FoodAlert
//
//  Created by Jack Li on 3/12/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "SimpleListViewController.h"

@interface SearchViewController : UIViewController

@property (nonatomic) MapViewController* mapViewController;
@property (nonatomic) SimpleListViewController* listViewController;

//@property (nonatomic, weak) SearchViewControllerDelegate* id;

@end

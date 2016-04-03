//
//  SearchViewController.h
//  FoodAlert
//
//  Created by Jack Li on 3/12/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "ListTableViewController.h"


@protocol SearchViewControllerDelegate <NSObject>
- (void) searchDidFinish;
@end


@interface SearchViewController : UIViewController

@property (nonatomic) MapViewController* mapViewController;

@property (weak, nonatomic) id<SearchViewControllerDelegate> delegate;

@end

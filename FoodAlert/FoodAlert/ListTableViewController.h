//
//  ListTableViewController.h
//  FoodAlert
//
//  Created by Jack Li on 3/16/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoinSide.h"

@interface ListTableViewController : UITableViewController <CoinSide>

//- (void) reloadTableView; // take out when savedItems is KVO

@end

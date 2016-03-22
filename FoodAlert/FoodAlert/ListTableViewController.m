//
//  ListTableViewController.m
//  FoodAlert
//
//  Created by Jack Li on 3/16/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "ListTableViewController.h"
#import "DataSource.h"
#import "Spot.h"

@implementation ListTableViewController

- (void) reloadTableView {
    [self.tableView reloadData];
}

#pragma mark - CoinSide protocol

- (NSString*) buttonName {
    return NSLocalizedString(@"List", @"List button");
}

- (UIImage*) buttonImage {
    return [UIImage imageNamed:@"list"];
}

#pragma mark - TableView Data Source delegate methods

// numberOfSections defaults to 1

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [DataSource sharedInstance].savedSpots.count;
}

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"listCell" forIndexPath:indexPath];
    // does dequeue automatically create a new cell? it apparently does as long as supply reuse ID
    
    Spot* spot = [DataSource sharedInstance].savedSpots[indexPath.row];
    cell.textLabel.text = spot.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"coord: %f, %f", spot.coordinate.latitude, spot.coordinate.longitude];
    
    return cell;
}

@end

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

- (void) viewDidLoad {
    [[DataSource sharedInstance] addObserver:self forKeyPath:NSStringFromSelector(@selector(currentSearchedSpots)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}

- (void) dealloc {
    [[DataSource sharedInstance] removeObserver:self forKeyPath:NSStringFromSelector(@selector(currentSearchedSpots))];
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary<NSString*,id> *)change context:(void*)context {
    if (object == [DataSource sharedInstance] && [keyPath isEqualToString:NSStringFromSelector(@selector(currentSearchedSpots))]) {
        NSKeyValueChange kindOfChange = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
        if (kindOfChange == NSKeyValueChangeSetting) {
            // lazy for now (should just reload table rows relating to the search)
            [self.tableView reloadData];
        }
    }
}


// take out when KVO in
- (void) reloadTableView {
    [self.tableView reloadData];
}


#pragma mark - TableView Data Source delegate methods

// numberOfSections defaults to 1

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [DataSource sharedInstance].savedSpots.count + [DataSource sharedInstance].currentSearchedSpots.count;
}

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"listCell" forIndexPath:indexPath];
    // does dequeue automatically create a new cell? it apparently does as long as supply reuse ID
    
    Spot* spot;
    NSArray* savedSpotsHelper = [DataSource sharedInstance].savedSpots;
    if (indexPath.row < savedSpotsHelper.count) {
        spot = savedSpotsHelper[indexPath.row];
    } else {
        spot = [DataSource sharedInstance].currentSearchedSpots[indexPath.row - savedSpotsHelper.count];
    }
    cell.textLabel.text = spot.title;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"coord: %f, %f", spot.coordinate.latitude, spot.coordinate.longitude];
    
    return cell;
}

#pragma mark - CoinSide protocol methods

- (NSString*) buttonName {
    return NSLocalizedString(@"List", @"List button");
}

- (UIImage*) buttonImage {
    return [UIImage imageNamed:@"list"];
}

@end

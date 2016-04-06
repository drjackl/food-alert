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


static const NSInteger SearchSection = 0;
static const NSInteger SavedSection = 1;

@implementation ListTableViewController

- (void) viewDidLoad {
    [[DataSource sharedInstance] addObserver:self forKeyPath:NSStringFromSelector(@selector(currentSearchedSpots)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [[DataSource sharedInstance] addObserver:self forKeyPath:NSStringFromSelector(@selector(savedSpotsBeingShown)) options:0 context:nil];
}

- (void) dealloc {
    [[DataSource sharedInstance] removeObserver:self forKeyPath:NSStringFromSelector(@selector(currentSearchedSpots))];
    [[DataSource sharedInstance] removeObserver:self forKeyPath:NSStringFromSelector(@selector(savedSpotsBeingShown))];
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary<NSString*,id> *)change context:(void*)context {
    if (object == [DataSource sharedInstance]) {
        
        // search spots
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(currentSearchedSpots))]) {
            NSKeyValueChange kindOfChange = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
            if (kindOfChange == NSKeyValueChangeSetting) {
                // lazy for now (should just reload table rows relating to the search)
                [self.tableView reloadData];
            }
        }
        
        // saved spots
        else if ([keyPath isEqualToString:NSStringFromSelector(@selector(savedSpotsBeingShown))]) {
            NSKeyValueChange kindOfChange = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
            if (kindOfChange == NSKeyValueChangeSetting) {
                // lazy for now (should just reload rows related to saved spots)
                [self.tableView reloadData];
            }
        }
    }
}


#pragma mark - TableView Data Source delegate methods

// numberOfSections defaults to 1
- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    return 2;
}

- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SearchSection:
            return NSLocalizedString(@"Search Results", @"search results section");
        case SavedSection:
            return NSLocalizedString(@"Saved Spots", @"saved spots section");
    }
    return NSLocalizedString(@"Null section", @"section that shouldn't be gotten to");
}

//// for table navigation (like direct scrolling, right side of table)
//- (NSArray<NSString*> *)sectionIndexTitlesForTableView:(UITableView*)tableView {
//    return @[NSLocalizedString(@"Search Results", @"search results section"),
//             NSLocalizedString(@"Saved Spots", @"saved spots section"),
//             NSLocalizedString(@"Null section", @"section that shouldn't be gotten to"),
//             @"What 4"];
//}

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SearchSection:
            return [DataSource sharedInstance].currentSearchedSpots.count;
        case SavedSection:
            return [DataSource sharedInstance].savedSpotsBeingShown.count;
    }
    return 0; // should never get here
    //return [DataSource sharedInstance].savedSpots.count + [DataSource sharedInstance].currentSearchedSpots.count;
}

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"listCell" forIndexPath:indexPath];
    // does dequeue automatically create a new cell? it apparently does as long as supply reuse ID
    
    Spot* spot;
    NSString* spotIconIdentifier;
    if (indexPath.section == SearchSection) {
        spot = [DataSource sharedInstance].currentSearchedSpots[indexPath.row];
        spotIconIdentifier = @"spotSearched";
    } else if (indexPath.section == SavedSection) {
        spot = [DataSource sharedInstance].savedSpotsBeingShown[indexPath.row];
        spotIconIdentifier = @"spotSaved";
    }
    
    // when used subtitle or title layout
    //cell.textLabel.text = spot.title;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"coord: %f, %f", spot.coordinate.latitude, spot.coordinate.longitude];

    // now using custom layout to have an icon (along with title and subtitle)
    UIImageView* listIconView = (UIImageView*)[cell viewWithTag:111];
    listIconView.image = [UIImage imageNamed:spotIconIdentifier];

    UILabel* listTitleLabel = (UILabel*)[cell viewWithTag:112];
    listTitleLabel.text = spot.title;
    UILabel* listSubtitleLabel = (UILabel*)[cell viewWithTag:113];
    
    // subtitle use to be address before notes feature
    //NSArray* addressLines = spot.addressDictionary[@"FormattedAddressLines"];
    //NSString* addressString = [addressLines componentsJoinedByString:@", "];
    //listSubtitleLabel.text = [spot formattedAddressWithSeparator:@", "];//addressString;
    listSubtitleLabel.text = spot.notes;
    
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

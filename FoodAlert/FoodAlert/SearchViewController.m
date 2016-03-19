//
//  SearchViewController.m
//  FoodAlert
//
//  Created by Jack Li on 3/12/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "SearchViewController.h"
#import <MapKit/MapKit.h>
#import "Spot.h"

@interface SearchViewController () <UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.searchBar.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*) name {
    return NSLocalizedString(@"List", @"List button");
}

// search bar delegate to execute search once entered
- (void) searchBarSearchButtonClicked:(UISearchBar*)searchBar {
    NSLog(@"Search button clicked with text: %@", searchBar.text);
    
    // simple search query from Apple's Location/Maps Programming Guide
    // 1. setup search request
    MKLocalSearchRequest* request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = searchBar.text;
    request.region = [self.mapViewController currentRegion]; // get region
    //self.mapViewController.currentRegion;
    
    // 2. setup search
    MKLocalSearch* search = [[MKLocalSearch alloc] initWithRequest:request];
    
    // 3. start search and get results
    [search startWithCompletionHandler:^(MKLocalSearchResponse*_Nullable response, NSError*_Nullable error) {
        NSMutableString* results = [NSMutableString new];
        NSMutableArray* spotsArray = [NSMutableArray new];
        [response.mapItems enumerateObjectsUsingBlock:^(MKMapItem*_Nonnull item, NSUInteger i, BOOL*_Nonnull stop) {
            //NSLog(@"Item %ld: %@", i, item);
            [results appendFormat:@"Item %ld: %@\n", i, item];
            Spot* spot = [[Spot alloc] initWithTitle:item.name coordinates:item.placemark.location.coordinate];
            [spotsArray addObject:spot];
        }];
        //NSLog(@"Results String:\n%@", results);
        [self.listViewController.textView setText:results];
        [self.mapViewController addSpots:spotsArray];
    }];
}

//// this doesn't start a search
//- (void) searchBarTextDidEndEditing:(UISearchBar*)searchBar {
//    NSLog(@"Search did end editing: %@", searchBar.text);
//}

//// for a type-to-filter-dropdown/type-to-suggest-autocomplete feature
//- (void) searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)searchText {
//    NSLog(@"Text did change: %@", searchText);
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

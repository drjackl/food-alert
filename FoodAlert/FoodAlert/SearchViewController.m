//
//  SearchViewController.m
//  FoodAlert
//
//  Created by Jack Li on 3/12/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "SearchViewController.h"
#import <MapKit/MapKit.h>
//#import <AddressBookUI/AddressBookUI.h>
#import "Spot.h"
#import "DataSource.h"


@interface SearchViewController () <UISearchBarDelegate, NSXMLParserDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *suggestionsTableView;
// data for saved suggestions list
@property (nonatomic) NSArray* savedSuggestionsArray;
// data for google suggest (and xml parsing)
@property (nonatomic) NSString* currentElement;
@property (nonatomic) NSMutableString* foundValue;
@property (nonatomic) NSMutableArray* googleSuggestionsArray;
@end

static const NSInteger SavedSuggestionSection = 0;
static const NSInteger GoogleSuggestionSection = 1;

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.searchBar.delegate = self;
    
    //self.savedSuggestionsArray = [NSMutableArray new];
    
    self.foundValue = [NSMutableString string];
    self.googleSuggestionsArray = [NSMutableArray array];
    
    // Table data/delegate related
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated. (also in TableVC)
}

- (void) conductSearchWithQuery:(NSString*)queryText {
    // simple search query from Apple's Location/Maps Programming Guide
    // 1. setup search request
    MKLocalSearchRequest* request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = queryText;
    request.region = [self.mapViewController currentRegion]; // get region
    //self.mapViewController.currentRegion;
    
    // 2. setup search
    MKLocalSearch* search = [[MKLocalSearch alloc] initWithRequest:request];
    
    // 3. start search and get results
    [search startWithCompletionHandler:^(MKLocalSearchResponse*_Nullable response, NSError*_Nullable error) {
        //NSMutableString* results = [NSMutableString new];
        NSMutableArray* spotsArray = [NSMutableArray new];
        [response.mapItems enumerateObjectsUsingBlock:^(MKMapItem*_Nonnull item, NSUInteger i, BOOL*_Nonnull stop) {
            NSLog(@"Item %ld: %@", i, item);
            //[results appendFormat:@"Item %ld: %@\n", i, item];
            Spot* spot = [[Spot alloc] initWithCoordinates:item.placemark.location.coordinate title:item.name addressDictionary:item.placemark.addressDictionary phone:item.phoneNumber url:item.url];
            [spotsArray addObject:spot];
        }];
        //NSLog(@"Results String:\n%@", results);
        //[self.listViewController.textView setText:results];
        //[self.mapViewController addSpots:spotsArray];
        [DataSource sharedInstance].currentSearchedSpots = spotsArray;
    }];
    
    [self.delegate searchDidFinish];
    [self.searchBar resignFirstResponder];
    //[delegate searchBarDidHide:searchBar];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
//    int sectionCount = 0;
//    if (self.savedSuggestionsArray.count > 0) {
//        sectionCount++;
//    }
//    if (self.googleSuggestionsArray.count > 0) {
//        sectionCount++;
//    }
//    return sectionCount;
    return 2;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SavedSuggestionSection:
            return self.savedSuggestionsArray.count;
            
        case GoogleSuggestionSection:
            return MIN(5, self.googleSuggestionsArray.count);
    }
    return 0; // should never get here
}


- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* cell;
    
    // Configure the cell...
    switch (indexPath.section) {
        case SavedSuggestionSection: { // need braces do declare variables like Spot?
            cell = [tableView dequeueReusableCellWithIdentifier:@"savedSuggestCell" forIndexPath:indexPath];
            Spot* spot = self.savedSuggestionsArray[indexPath.row];
            //cell.textLabel.text = spot.title; // changed to custom to have icon
            ((UILabel*)[cell viewWithTag:111]).text = spot.title;
            break;
        }
        case GoogleSuggestionSection:
            cell = [tableView dequeueReusableCellWithIdentifier:@"googleSuggestCell" forIndexPath:indexPath];
            cell.textLabel.text = self.googleSuggestionsArray[indexPath.row];
            break;
    }
    
    return cell;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SavedSuggestionSection:
            return NSLocalizedString(@"Saved Suggestions", @"saved spots suggestions");
            
        case GoogleSuggestionSection:
            return NSLocalizedString(@"Google Suggestions", @"google suggestions");
    }
    return nil;
}


 

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - TableView delegate methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    NSString* queryText;
    if (indexPath.section == SavedSuggestionSection) {
        queryText = ((Spot*)self.savedSuggestionsArray[indexPath.row]).title;
    } else { // GoogleSuggestionSection
        queryText = self.googleSuggestionsArray[indexPath.row];
    }
    [self conductSearchWithQuery:queryText];
}

#pragma mark - Search Bar delegate methods

// search bar delegate to execute search once entered
- (void) searchBarSearchButtonClicked:(UISearchBar*)searchBar {
    NSLog(@"Search button clicked with text: %@", searchBar.text);
    
    [self conductSearchWithQuery:searchBar.text];
}

// needs a delegate or some communication to tell parent to toggle container view in CoinVC, not just dismiss this VC
- (void) searchBarCancelButtonClicked:(UISearchBar*)searchBar {
    [self.delegate searchDidFinish];
}

//// this doesn't start a search
//- (void) searchBarTextDidEndEditing:(UISearchBar*)searchBar {
//    NSLog(@"Search did end editing: %@", searchBar.text);
//}

// for a type-to-filter-dropdown/type-to-suggest-autocomplete feature
- (void) searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)searchText {
    //NSLog(@"Text did change: %@", searchText);
    
    // saved spots suggest
    self.savedSuggestionsArray = [[DataSource sharedInstance].savedSpots filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title contains[cd] %@", searchText]];
    
    // google suggest
    NSString* noSpaceSearchText = [searchText stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString* urlString = [NSString stringWithFormat:@"http://suggestqueries.google.com/complete/search?output=toolbar&hl=en&q=%@", noSpaceSearchText];
    NSURL* url = [NSURL URLWithString:urlString];
    
    if (url) {
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        
        // in Simple Browser proj, would just load the request; here, we get data like Picsta
        NSURLResponse* response;
        NSError* webError;
        NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&webError]; // deprecated, use NSURLSession dataTask
        
        if (responseData) {
            //NSError* jsonError; // not JSON, so can't use
            //NSDictionary* suggestsDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
            //NSXMLParser* xmlParser = [NSXMLParser alloc] initWithContentsOfURL:url;
            
            NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData:responseData];
            xmlParser.delegate = self;
            [xmlParser parse];
            
            [self.suggestionsTableView reloadData];
        }
        
//        NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
//        xmlParser.delegate = self;
//        [xmlParser parse];
        
    }
}

#pragma mark - XML Parser delegate methods

- (void) parserDidStartDocument:(NSXMLParser *)parser {
    [self.googleSuggestionsArray removeAllObjects];
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    self.currentElement = elementName;
    if ([elementName isEqualToString:@"suggestion"]) {
        [self.foundValue setString:attributeDict[@"data"]];
        [self.googleSuggestionsArray addObject:[self.foundValue copy]];
    }
}

//- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
//    if ([self.currentElement isEqualToString:@"suggestion"]) {
//        //[self.foundValue appendString:string];
//        NSLog(@"foundValue: %@", self.foundValue);
//    }
//}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([self.currentElement isEqualToString:@"suggestion"]) {
        //[self.googleSuggestionsArray addObject:[self.foundValue copy]]; // somehow this getting called twice
        [self.foundValue setString:@""];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation (was also in TableVC)
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end

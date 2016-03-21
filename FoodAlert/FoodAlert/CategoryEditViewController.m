//
//  CategoryEditViewController.m
//  FoodAlert
//
//  Created by Jack Li on 3/19/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "CategoryEditViewController.h"
#import "DataSource.h"
#import "Categorie.h"

@implementation CategoryEditViewController

#pragma mark - TableView Data Source delegate methods

// numberOfSections defaults to 1

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [DataSource sharedInstance].categories.count;
}

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"categoryEditingCell" forIndexPath:indexPath];
    // does dequeue automatically create a new cell? it apparently does as long as supply reuse ID
    
    Categorie* category = [DataSource sharedInstance].categories[indexPath.row];
    
    //cell.textLabel.text = category.title;
    UITextField* nameField = (UITextField*)[cell viewWithTag:101];
    nameField.text = category.title;
    [nameField addTarget:self action:@selector(setCategoryTitle) forControlEvents:UIControlEventEditingChanged];
    
    cell.backgroundColor = category.color;
    
    return cell;
}

- (void) setCategoryTitle {
    NSLog(@"setting category title");
}

@end

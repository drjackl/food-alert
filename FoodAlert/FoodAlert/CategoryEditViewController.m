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
#import "CategoryEditViewCell.h"

@implementation CategoryEditViewController

#pragma mark - TableView Data Source delegate methods

// numberOfSections defaults to 1

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [DataSource sharedInstance].categories.count;
}

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    CategoryEditViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"catEditCell" forIndexPath:indexPath];
    
    Categorie* category = [DataSource sharedInstance].categories[indexPath.row];

    // switch Custom UITableViewCell for real custom CategoryEditViewCell
//    //cell.textLabel.text = category.title; // switch Basic title for Custom textField
//    UITextField* nameField = (UITextField*)[cell viewWithTag:101];
//    nameField.text = category.title;
//    [nameField addTarget:self action:@selector(setCategoryTitle) forControlEvents:UIControlEventEditingChanged];
//    
//    cell.backgroundColor = category.color;
    
    cell.category = category;
    
    return cell;
}

- (IBAction) dismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self dismissViewController]; // oops i was calling myself
}

- (void) setCategoryTitle {
    NSLog(@"setting category title");
}

@end

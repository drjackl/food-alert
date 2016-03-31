//
//  CategorySelectViewController.m
//  FoodAlert
//
//  Created by Jack Li on 3/24/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "CategorySelectViewController.h"
#import "DataSource.h"
#import "Categorie.h"
#import "CategoryPresentationController.h"

@interface CategorySelectViewController () <UIViewControllerTransitioningDelegate, UITableViewDelegate>

@end

@implementation CategorySelectViewController

// initWithCoder, commonInit, presentationControllerFor... are all based off the iOS8 UIPresCtl proj

// thought the swift method was regular init, argh!
- (instancetype) initWithCoder:(NSCoder*)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.transitioningDelegate = self;
    self.modalPresentationStyle = UIModalPresentationCustom;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Table View data source/delegate
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;'
    
    self.view.layer.cornerRadius = 10.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController*) presentationControllerForPresentedViewController:(UIViewController*)presented presentingViewController:(UIViewController*)presenting sourceViewController:(UIViewController*)source {
    if (presented == self) {
        return [[CategoryPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting pack:NO];
    }
    return nil;
}

#pragma mark - Table View delegate

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    // notify sender of selected category
    [self.delegate didSelectCategory:[DataSource sharedInstance].categories[indexPath.row]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table View data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return [DataSource sharedInstance].categories.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categorySelectCell" forIndexPath:indexPath];
    
    // Configure the cell...
    Categorie* category = [DataSource sharedInstance].categories[indexPath.row];
    cell.textLabel.text = category.title;
    cell.backgroundColor = category.color;
    
    return cell;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

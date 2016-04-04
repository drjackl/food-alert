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
@property (weak, nonatomic) IBOutlet UITableView *categoriesTableView;
@end

@implementation CategorySelectViewController

// initWithCoder, commonInit, presentationControllerFor... are all based off the iOS8 UIPresCtl proj

// thought the swift method was regular init, argh!
- (instancetype) initWithCoder:(NSCoder*)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        
        [[DataSource sharedInstance] addObserver:self forKeyPath:NSStringFromSelector(@selector(categories)) options:0 context:nil];
    }
    return self;
}

- (void) dealloc {
    [[DataSource sharedInstance] removeObserver:self forKeyPath:NSStringFromSelector(@selector(categories))];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Table View data source/delegate
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;'
    
    self.view.layer.cornerRadius = 10.0;
    self.view.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void*)context {
    if (object == [DataSource sharedInstance] && [keyPath isEqualToString:NSStringFromSelector(@selector(categories))]) {
        NSKeyValueChange kindOfChange = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
        if (kindOfChange == NSKeyValueChangeInsertion ||
            kindOfChange == NSKeyValueChangeRemoval ||
            kindOfChange == NSKeyValueChangeSetting) {
            [self.categoriesTableView reloadData];
        }
    }
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
    NSInteger i = indexPath.row;
    if ((self.isFirstItemNone && i==0) ||
        (!self.isFirstItemNone && i==[DataSource sharedInstance].categories.count)) {
        [self.delegate didSelectCategory:nil];
    } else {
        if (self.isFirstItemNone) {
            i--;
        }
        [self.delegate didSelectCategory:[DataSource sharedInstance].categories[i]];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table View data source

// numberOfSections defaults to 1
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return [DataSource sharedInstance].categories.count + 1; // add one for none item
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categorySelectCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSInteger i = indexPath.row;
    
    // if none item (first or last depending on isFirstItemNone), return cell for none item
    if ((self.isFirstItemNone && i==0) ||
        (!self.isFirstItemNone && i==[DataSource sharedInstance].categories.count)) {
        cell.textLabel.text = NSLocalizedString(@"<no category>", @"option for selecting nothing (no categories)");
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
    }
    
    // if firstItemNone, decrement index to get right index for the categories model
    if (self.isFirstItemNone) {
        i--;
    }
    
    Categorie* category = [DataSource sharedInstance].categories[i];
    cell.textLabel.text = category.title;
    cell.backgroundColor = category.color;
    
    return cell;
}



// Override to support conditional editing of the table view.
// (next method tableView:commitEditingStyle: must also be uncommented for Delete to appear)
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    NSInteger i = indexPath.row;
    if ((self.isFirstItemNone && i==0) ||
        (!self.isFirstItemNone && i==[DataSource sharedInstance].categories.count)) {
        return NO;
    }
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        NSInteger i = indexPath.row;
        if (self.isFirstItemNone) {
            i--;
        }
        
        [[DataSource sharedInstance] deleteCategoryAtIndex:i];
    }
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
}


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

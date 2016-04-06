//
//  CategoryAddViewController.m
//  FoodAlert
//
//  Created by Jack Li on 3/30/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "CategoryAddViewController.h"
#import "DataSource.h"
#import "CategoryPresentationController.h"

@interface CategoryAddViewController () <UIViewControllerTransitioningDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UILabel *swipeForColorLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (nonatomic) int arrayIndex;
@end

@implementation CategoryAddViewController

// storyboard uses this method to instantiate UIVCs
- (instancetype)initWithCoder:(NSCoder*)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([DataSource sharedInstance].unusedColors.count > 0) {
        self.arrayIndex = 0;
        //self.nameTextField.enabled = YES;
        self.colorView.backgroundColor = [DataSource sharedInstance].unusedColors[0];
    } else {
        self.arrayIndex = -1;
        self.nameTextField.enabled = NO;
        self.colorView.backgroundColor = [UIColor whiteColor];
        self.swipeForColorLabel.text = NSLocalizedString(@"No more colors for categories", @"Array of colors to create categories is empty description");
        self.addButton.enabled = NO;
    }
    
    self.view.layer.cornerRadius = 10.0;
    self.view.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    if (presented == self) {
        return [[CategoryPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting pack:YES];
    }
    return nil;
}


#pragma mark - IBActions

- (IBAction) addCategory {
    [[DataSource sharedInstance] addCategoryWithName:self.nameTextField.text fromColorAtIndex:self.arrayIndex];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) swipeLeftGestureDidFire:(UISwipeGestureRecognizer*)sender {
    if (self.arrayIndex != -1) {
        //NSLog(@"Index %d out of total %ld", self.arrayIndex, [DataSource sharedInstance].unusedColors.count);
        self.arrayIndex = (self.arrayIndex+1) % [DataSource sharedInstance].unusedColors.count;
        self.colorView.backgroundColor = [DataSource sharedInstance].unusedColors[self.arrayIndex];
    }
}

- (IBAction) swipeRightGestureDidFire:(UISwipeGestureRecognizer*)sender {
    if (self.arrayIndex != -1) {
        //NSLog(@"Index %d out of total %ld", self.arrayIndex, [DataSource sharedInstance].unusedColors.count);
        int count = (int)[DataSource sharedInstance].unusedColors.count;
        self.arrayIndex = (self.arrayIndex-1+count) % count; // add count to get wraparound
        self.colorView.backgroundColor = [DataSource sharedInstance].unusedColors[self.arrayIndex];
    }
}

- (IBAction) dismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

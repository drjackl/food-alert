//
//  CoinViewController.m
//  FoodAlert
//
//  Created by Jack Li on 3/15/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "CoinViewController.h"

@interface CoinViewController ()
@property (nonatomic) UIView* currentView;
// Outlets
@property (weak, nonatomic) IBOutlet UIView* view1;
@property (weak, nonatomic) IBOutlet UIView* view2;
@end

@implementation CoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.currentView = self.view1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) switchViewControllers {
    // if currently on view1
    if (self.currentView == self.view1) {
        self.view2.alpha = 1.0; // show view2 by making opaque
        self.currentView = self.view2;
    } else {
        self.view2.alpha = 0.0; // show view1 by making view2 clear
        self.currentView = self.view1;
    }
    NSLog(@"Button pressed!");
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

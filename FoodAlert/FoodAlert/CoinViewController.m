//
//  CoinViewController.m
//  FoodAlert
//
//  Created by Jack Li on 3/15/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "CoinViewController.h"
//#import "CoinSideViewController.h" // not generic anymore
#import "MapViewController.h"
//#import "SimpleListViewController.h"
#import "ListTableViewController.h"
#import "SearchViewController.h"
#import "DataSource.h" // remove when KVO in
#import "CoinSide.h"
//#import "CategorySelectViewController.h"

@interface CoinViewController () <SearchViewControllerDelegate/*, CategorySelectViewControllerDelegate*/>
@property (nonatomic) UIView* currentView;
@property (nonatomic) MapViewController<CoinSide>* mapViewController; // if generic, just be CoinSide
//@property (nonatomic) SimpleListViewController* listViewController;
@property (nonatomic) ListTableViewController<CoinSide>* listViewController; // just needs be CoinSide
@property (nonatomic) SearchViewController* searchViewController;
// Outlets
@property (weak, nonatomic) IBOutlet UIView* view1; // mapVC container
@property (weak, nonatomic) IBOutlet UIView* view2; // listVC container
@property (weak, nonatomic) IBOutlet UIButton* otherViewButton;
@property (weak, nonatomic) IBOutlet UIView* searchView; // searchVC container
@end

@implementation CoinViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.currentView = self.view1;
    self.searchViewController.mapViewController = self.mapViewController;
    self.searchViewController.listViewController = self.listViewController;
    
    self.searchViewController.delegate = self;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //NSLog(@"segue ID: %@", segue.identifier);
    if ([segue.identifier isEqualToString:@"mapViewController"]) {
        self.mapViewController = (MapViewController*) segue.destinationViewController;
        [DataSource sharedInstance].mapVC = self.mapViewController; // remove when KVO in
    } else if ([segue.identifier isEqualToString:@"listEmbedSegue"]) {
        self.listViewController = (ListTableViewController*) segue.destinationViewController;
        [DataSource sharedInstance].listVC = self.listViewController; // remove when KVO in
    } else if ([segue.identifier isEqualToString:@"searchEmbedSegue"]) {
        self.searchViewController = (SearchViewController*) segue.destinationViewController;
    }
}

#pragma mark - Show/Hide

- (IBAction) switchViewControllers {
    // fade transition
    if (self.currentView == self.view1) { // if currently on view1
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            self.view2.alpha = 1.0; // show view2 by making opaque
        } completion:nil];
        self.currentView = self.view2;
    } else {
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            self.view2.alpha = 0.0; // show view1 by making view2 clear
        } completion:nil];
        self.currentView = self.view1;
    }
    
    //UIView* otherView = self.currentView==self.view1 ? self.view2 : self.view1; // pre transition customization
    
    // coin flip back and forth transition
    //    UIView* otherView;
    //    UIViewAnimationOptions transition;
    //    if (self.currentView == self.view1) {
    //        otherView = self.view2;
    //        transition = UIViewAnimationOptionTransitionFlipFromLeft;
    //    } else {
    //        otherView = self.view1;
    //        transition = UIViewAnimationOptionTransitionFlipFromRight;
    //    }
    //    [UIView transitionFromView:self.currentView toView:otherView duration:0.5 options:transition completion:nil];
    //    self.currentView = otherView;
}

- (IBAction) showSearch {
    [UIView animateWithDuration:0.5 animations:^{
        self.searchView.alpha = 1;//((int)self.searchView.alpha + 1) % 2; // toggling here
    }];
}

//#pragma mark - CatSelect VC delegate
//
//- (void) didSelectCategory:(Categorie*)category {
//    
//}

#pragma mark - Search VC delegate

- (void) searchDidFinish {
    [UIView animateWithDuration:0.5 animations:^{
        self.searchView.alpha = 0;
    }];
}

- (IBAction) showCategories {
}

#pragma mark - Accessors

// part of setting the current view is also ensuring the Other View button gets set to the otherView
- (void) setCurrentView:(UIView*)currentView {
    _currentView = currentView;
    //NSString* otherViewString = currentView==self.view1 ? NSLocalizedString(@"View 2", @"View 2") : NSLocalizedString(@"View 1", @"View 1");
    //NSString* otherViewString = currentView==self.view1 ? [self.listViewController buttonName] : [self.mapViewController buttonName];
    //[self.otherViewButton setTitle:otherViewString forState:UIControlStateNormal];
    UIImage* otherViewImage = currentView==self.view1 ? [self.listViewController buttonImage] : [self.mapViewController buttonImage];
    [self.otherViewButton setImage:otherViewImage forState:UIControlStateNormal];
}

@end

//
//  CoinViewController.m
//  FoodAlert
//
//  Created by Jack Li on 3/15/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "CoinViewController.h"
#import "MapViewController.h"
#import "ListTableViewController.h"
#import "SearchViewController.h"
#import "DataSource.h" // necessary for filtering
#import "CoinSide.h"
#import "CategorySelectViewController.h"

@interface CoinViewController () <SearchViewControllerDelegate, CategorySelectViewControllerDelegate>
@property (nonatomic) UIView* currentView;
@property (nonatomic) MapViewController<CoinSide>* mapViewController; // needed for search
@property (nonatomic) ListTableViewController<CoinSide>* listViewController; // just needs be CoinSide
//@property (nonatomic) UIViewController<CoinSide>* viewController1;
//@property (nonatomic) UIViewController<CoinSide>* viewController2;
@property (nonatomic) SearchViewController* searchViewController;
@property (nonatomic) CategorySelectViewController* categoryFilterModal;
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
    //self.searchViewController.listViewController = self.listViewController; // shouldn't need
    
    
    
    //self.categoryFilterModal.delegate = self; // too early, should be done on init (segue)
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //NSLog(@"segue ID: %@", segue.identifier);
    if ([segue.identifier isEqualToString:@"mapViewController"]) {
        self.mapViewController = (MapViewController*) segue.destinationViewController;
        //[DataSource sharedInstance].mapVC = self.mapViewController; // remove when KVO in
    } else if ([segue.identifier isEqualToString:@"listEmbedSegue"]) {
        self.listViewController = (ListTableViewController*) segue.destinationViewController;
        //[DataSource sharedInstance].listVC = self.listViewController; // remove when KVO in
    } else if ([segue.identifier isEqualToString:@"searchEmbedSegue"]) {
        self.searchViewController = (SearchViewController*) segue.destinationViewController;
        self.searchViewController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"categoryFilter"]) {
        self.categoryFilterModal = (CategorySelectViewController*) segue.destinationViewController;
        self.categoryFilterModal.delegate = self;
        self.categoryFilterModal.isFirstItemNone = YES;
    }
}

#pragma mark - Show/Hide

- (IBAction) switchViewControllers {
//    // fade transition
//    if (self.currentView == self.view1) { // if currently on view1
//        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
//            self.view2.alpha = 1.0; // show view2 by making opaque
//        } completion:nil];
//        self.currentView = self.view2;
//    } else {
//        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
//            self.view2.alpha = 0.0; // show view1 by making view2 clear
//        } completion:nil];
//        self.currentView = self.view1;
//    }
    
    // fade transition refactored
    CGFloat opacity;
    if (self.currentView == self.view1) {
        self.currentView = self.view2;
        opacity = 1.0; // show view2 by making opaque
    } else {
        self.currentView = self.view1;
        opacity = 0.0; // show view1 by making view2 clear
    }
    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        self.view2.alpha = opacity;
    } completion:nil];
    
//    // fade transition: two if-statements
//    self.currentView = self.currentView==self.view1 ? self.view2 : self.view1;
//    CGFloat opacity = self.currentView==self.view1 ? 1.0 : 0.0;
//    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
//        self.view2.alpha = opacity;
//    } completion:nil];
}

- (IBAction) showSearch {
    [UIView animateWithDuration:0.5 animations:^{
        self.searchView.alpha = 1;//((int)self.searchView.alpha + 1) % 2; // toggling here
    }];
}

#pragma mark - CatSelect VC delegate

- (void) didSelectCategory:(Categorie*)category {
    [[DataSource sharedInstance] filterSavedSpotsWithCategory:category];
}

#pragma mark - Search VC delegate

- (void) searchDidFinish {
    [UIView animateWithDuration:0.5 animations:^{
        self.searchView.alpha = 0;
    }];
}

#pragma mark - Accessors

// part of setting the current view is also ensuring the Other View button gets set to the otherView
- (void) setCurrentView:(UIView*)currentView {
    _currentView = currentView;

    // used buttonNames before
    UIImage* otherViewImage = currentView==self.view1 ? [self.listViewController buttonImage] : [self.mapViewController buttonImage];
    [self.otherViewButton setImage:otherViewImage forState:UIControlStateNormal];
}

@end

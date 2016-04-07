//
//  CalloutViewController.m
//  FoodAlert
//
//  Created by Jack Li on 3/28/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "CalloutViewController.h"
#import "Categorie.h"
#import "DataSource.h"
#import "CategorySelectViewController.h"

@interface CalloutViewController () <CategorySelectViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UIButton* saveButton;
@property (weak, nonatomic) IBOutlet UIButton* categoryButton;
@property (weak, nonatomic) IBOutlet UIButton* driveButton;
@property (weak, nonatomic) IBOutlet UIButton* shareButton;
@property (weak, nonatomic) IBOutlet UIButton* deleteButton;
@end

@implementation CalloutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self updateViewBasedOnSpot];
    //[self.categoryButton addTarget:self action:@selector(popupCategorySelect) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void) prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"categorySelect"]) {
        CategorySelectViewController* categorySelectModal = (CategorySelectViewController*)segue.destinationViewController;
        categorySelectModal.delegate = self;
        categorySelectModal.isFirstItemNone = NO;
    }
}

#pragma mark - Accessors & View updates

// currently, only time spot set is when a spot gets selected on map (can't select same spot)
- (void) setSpot:(Spot*)spot {
    [_spot removeObserver:self forKeyPath:NSStringFromSelector(@selector(category))];
    [spot addObserver:self forKeyPath:NSStringFromSelector(@selector(category)) options:0 context:nil];
    
    _spot = spot;
    
    // interesting view hasn't been loaded here yet (initially it seems)
    [self updateViewBasedOnSpot]; // needed for subsequent annotation taps
}

- (void) updateViewBasedOnSpot {
    self.titleLabel.text = self.spot.title;
    
    // userInteractionEnabled still leaves button blue, misleading
    self.saveButton.enabled = !self.spot.saved;
    
    // category button
    [self updateCategoryButtonBasedOnSpot];
    
//    self.descriptionTextView.text = [NSString stringWithFormat:@"%@\n%@\n%@",
//                                     [self.spot formattedAddressWithSeparator:@"\n"],
//                                     self.spot.phone,
//                                     self.spot.url.absoluteString];
    self.descriptionTextView.text = self.spot.notes;
}

- (void) updateCategoryButtonBasedOnSpot {
    NSString* titleText = self.spot.category ? self.spot.category.title : NSLocalizedString(@"<no category>", @"default category label");
    [self.categoryButton setTitle:titleText forState:UIControlStateNormal];
    self.categoryButton.backgroundColor = self.spot.category.color;
}

// just need to listen if this category gets deleted (checks for change setting types)
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == self.spot && [keyPath isEqualToString:NSStringFromSelector(@selector(category))]) {
        NSKeyValueChange changeKind = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
        if (changeKind == NSKeyValueChangeSetting) {
            [self updateCategoryButtonBasedOnSpot];
        }
    }
}


#pragma mark - IBActions

- (IBAction) saveSpot {
    self.saveButton.enabled = NO; // disable right away (must do this if in list view too)
    
    [[DataSource sharedInstance] saveSpot:self.spot];
}

- (IBAction) popupCategorySelect {
    [self performSegueWithIdentifier:@"categorySelect" sender:self];
}

- (IBAction) directionsToSpot {
    // need to get current location and this spot's map item
    [self.delegate didPressDirectionsButton];
}

- (IBAction) shareSpot {
    NSArray* itemsToShare = @[self.spot.title, self.spot.addressDictionary, self.spot.notes, /*self.spot.phone, self.spot.url*/];
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (IBAction) deleteSpot {
    [[DataSource sharedInstance] deleteSpot:self.spot];
}


#pragma mark - CatSelect VC delegate methods

- (void) didSelectCategory:(Categorie*)category {
    // only set category if different from current category
    if (self.spot.category != category) {
        //self.spot.category = category; // simple solution
        //[category addSpot:self.spot]; // set spot <--> category
        // linking spot <--> cat
        [[DataSource sharedInstance] setCategory:category forSpot:self.spot];
        
        // update category title and color
        [self.categoryButton setTitle:category.title forState:UIControlStateNormal];
        self.categoryButton.backgroundColor = category.color;
        if (!category) {
            [self.categoryButton setTitle:NSLocalizedString(@"<no category>", @"nil category") forState:UIControlStateNormal];
            self.categoryButton.backgroundColor = [UIColor whiteColor];
        }
        
        // somehow, these aren't saving ... or are they now ...
        // these are called in setCategory above (not with easy solution)
        //[[DataSource sharedInstance] archiveCategories]; should only need savedSpots for basic
        //[[DataSource sharedInstance] archiveSavedSpots];
        
        //[[DataSource sharedInstance] archiveSavedSpots]; // simple solution
        
        // in strong/weak, already being archived in setCategory:forSpot:
    }
}


@end

//
//  CalloutViewController.m
//  FoodAlert
//
//  Created by Jack Li on 3/28/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "CalloutViewController.h"
#import "Categorie.h"

@interface CalloutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UIButton *driveButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@end

@implementation CalloutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self updateViewBasedOnSpot];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void) setSpot:(Spot*)spot {
//    _spot = spot;
//    
//    // interesting view hasn't been loaded here yet
//}

- (void) updateViewBasedOnSpot {
    self.titleLabel.text = self.spot.title;
    NSString* titleText = self.spot.category ? self.spot.category.title : NSLocalizedString(@"<category>", @"default category label");
    [self.categoryButton setTitle:titleText forState:UIControlStateNormal];
    self.categoryButton.backgroundColor = self.spot.category.color;
    
    self.descriptionTextView.text = [NSString stringWithFormat:@"%@\n%@\n%@",
                                     [self.spot formattedAddressWithSeparator:@"\n"],
                                     self.spot.phone,
                                     self.spot.url.absoluteString];
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

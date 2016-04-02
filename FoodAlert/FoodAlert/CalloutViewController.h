//
//  CalloutViewController.h
//  FoodAlert
//
//  Created by Jack Li on 3/28/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Spot.h"


@protocol CalloutViewControllerDelegate <NSObject>
- (void) didPressDirectionsButton;
@end


@interface CalloutViewController : UIViewController

@property (nonatomic) Spot* spot;

@property (weak, nonatomic) id<CalloutViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end

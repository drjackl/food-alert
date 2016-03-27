//
//  CategoryPresentationController.m
//  FoodAlert
//
//  Created by Jack Li on 3/24/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "CategoryPresentationController.h"

@interface CategoryPresentationController ()

@property (nonatomic) UIView* dimmingView;

@end

@implementation CategoryPresentationController

- (instancetype) initWithPresentedViewController:(UIViewController*)presentedViewController presentingViewController:(UIViewController*)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        self.dimmingView = [UIView new];
        self.dimmingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    }
    return self;
}

- (void) presentationTransitionWillBegin {
    [self.containerView addSubview:self.dimmingView];
    [self.dimmingView addSubview:self.presentedViewController.view];
    
    self.dimmingView.frame = self.containerView.frame; // argh, forgot frame
    
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentedViewController.transitionCoordinator;
    
    self.dimmingView.alpha = 0.0;
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.dimmingView.alpha = 1.0;
    } completion:nil];
}

- (CGRect) frameOfPresentedViewInContainerView {
    CGRect containerFrame = self.containerView.frame;
    CGRect frame = CGRectInset(containerFrame, 50.0, 50.0);
    return frame;
}

- (void) presentationTransitionDidEnd:(BOOL)completed {
    if (!completed) {
        [self.dimmingView removeFromSuperview];
    }
}

@end

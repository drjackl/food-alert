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
@property (nonatomic) BOOL pack;
@end

@implementation CategoryPresentationController

- (instancetype) initWithPresentedViewController:(UIViewController*)presentedViewController presentingViewController:(UIViewController*)presentingViewController pack:(BOOL)pack {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        self.dimmingView = [UIView new];
        self.dimmingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        [self.dimmingView addGestureRecognizer:tapGesture];
        
        self.pack = pack;
    }
    return self;
}

- (void) presentationTransitionWillBegin {
    [self.containerView addSubview:self.dimmingView];
    [self.dimmingView addSubview:self.presentedViewController.view];
    
    self.dimmingView.frame = self.containerView.frame; // argh, forgot frame
    
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentedViewController.transitionCoordinator;
    
    self.dimmingView.alpha = 0.0;
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        self.dimmingView.alpha = 1.0;
    } completion:nil];
}

- (CGRect) frameOfPresentedViewInContainerView {
    CGRect containerFrame = self.containerView.frame;
    CGFloat dx = 50.0, dy = 50.0;
    if (self.pack) {
        CGSize preferredModalSize = self.presentedViewController.preferredContentSize;
        dx = (CGRectGetMaxX(containerFrame) - preferredModalSize.width) / 2;
        dy = (CGRectGetMaxY(containerFrame) - preferredModalSize.height) / 2;
    }
    CGRect frame = CGRectInset(containerFrame, dx, dy);
    return frame;
}

- (void) presentationTransitionDidEnd:(BOOL)completed {
    if (!completed) {
        [self.dimmingView removeFromSuperview];
    }
}

- (void) tapFired:(UITapGestureRecognizer*)sender {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

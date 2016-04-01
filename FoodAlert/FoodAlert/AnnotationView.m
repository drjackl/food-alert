//
//  AnnotationView.m
//  FoodAlert
//
//  Created by Jack Li on 3/31/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "AnnotationView.h"

@implementation AnnotationView

#pragma mark - UIView Hit Testing override methods

// redefine a point to be inside if it's inside any subviews too
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    // in self coordinates
    BOOL isInside = CGRectContainsPoint(self.bounds, point);
    
    // if not inside AV (the pin image), check subviews (callout)
    if (!isInside) {
        for (UIView* subview in self.subviews) {
            // still in self coordinates, so children use their frame
            isInside = CGRectContainsPoint(subview.frame, point);
            if (isInside) {
                break;
            }
        }
    }
    return isInside;
}

// override so this AV brought to front if this point hits it or callout
- (UIView*) hitTest:(CGPoint)point withEvent:(UIEvent*)event {
    // super method calls pointInside on each subview, if YES, recurse on subview; else nil
    UIView* hitView = [super hitTest:point withEvent:event];
    
    // if self or subview (callout) was hit, bring view to front (override mapView)
    if (hitView) {
        [self.superview bringSubviewToFront:self];
    }
    return hitView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

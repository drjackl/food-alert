//
//  MapViewController.h
//  FoodAlert
//
//  Created by Jack Li on 3/12/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoinSide.h"
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <CoinSide>

- (MKCoordinateRegion) currentRegion;
//- (void) addSpots:(NSArray*)spotsArray;

@end

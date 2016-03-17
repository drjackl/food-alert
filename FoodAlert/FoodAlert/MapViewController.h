//
//  MapViewController.h
//  FoodAlert
//
//  Created by Jack Li on 3/12/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoinSideViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController : CoinSideViewController

- (MKCoordinateRegion) currentRegion;

@end

//
//  MapViewController.m
//  FoodAlert
//
//  Created by Jack Li on 3/12/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AnnotationView.h"
#import "Spot.h"
#import "DataSource.h"
#import "CategorySelectViewController.h"
#import "CalloutViewController.h"
#import "CategoryPresentationController.h"

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, CalloutViewControllerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView* mapView;

@property (nonatomic) CLLocationManager* locationManager;

@property (nonatomic) CategorySelectViewController* categorySelectModal;

@property (nonatomic) Spot* currentSelectedSpot; // for setting category and getting directions
//@property (nonatomic) MKAnnotationView* currentAnnotationView;

@property (nonatomic) CalloutViewController* calloutViewController;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mapView.delegate = self;
    
//    switch (CLLocationManager.authorizationStatus) {
//        case kCLAuthorizationStatusRestricted:
//        case kCLAuthorizationStatusDenied:
//            break;
//        default:
//            self.locationManager = [CLLocationManager new];
//            self.locationManager.delegate = self;
//        case kCLAuthorizationStatusNotDetermined:
//            [self.locationManager requestAlwaysAuthorization]; // needed post iOS 8
//        case kCLAuthorizationStatusAuthorizedWhenInUse:
            //[self.locationManager startUpdatingLocation];
            //[self.locationManager startMonitoringSignificantLocationChanges];
//    }
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    
    [self.locationManager requestAlwaysAuthorization];
    
    // maybe this isn't necessary if have delegate (this code put in delegate authChange method)
//    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways ||
//        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
//        self.mapView.showsUserLocation = YES; // checkmark exists in storyboard as another option
//        [self.locationManager startUpdatingLocation];
//    }
    
    //[self addSpotsForRegionMonitoring]; // should've known too early
    
    
    [[DataSource sharedInstance] addObserver:self forKeyPath:NSStringFromSelector(@selector(currentSearchedSpots)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [[DataSource sharedInstance] addObserver:self forKeyPath:NSStringFromSelector(@selector(savedSpotsBeingShown)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [[DataSource sharedInstance] addObserver:self forKeyPath:NSStringFromSelector(@selector(savedSpots)) options:0 context:nil]; // for region monitoring
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [[DataSource sharedInstance] removeObserver:self forKeyPath:NSStringFromSelector(@selector(currentSearchedSpots))];
    [[DataSource sharedInstance] removeObserver:self forKeyPath:NSStringFromSelector(@selector(savedSpotsBeingShown))];
    [[DataSource sharedInstance] removeObserver:self forKeyPath:NSStringFromSelector(@selector(savedSpots))];
}


/*#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

}*/


#pragma mark - KVO (searchSpots and savedSpotsBeingShown)

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary<NSString*,id>*)change context:(void*)context {
    if (object == [DataSource sharedInstance]) {
        // searched spots
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(currentSearchedSpots))]) {
            NSKeyValueChange kindOfChange = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
            if (kindOfChange == NSKeyValueChangeSetting) {
                // replace old if there's old
                [self.mapView removeAnnotations:change[NSKeyValueChangeOldKey]];
                // set new
                [self.mapView addAnnotations:change[NSKeyValueChangeNewKey]];
            }
        }
        
        // saved spots being shown
        else if ([keyPath isEqualToString:NSStringFromSelector(@selector(savedSpotsBeingShown))]) {
            NSKeyValueChange kindOfChange = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
            if (kindOfChange == NSKeyValueChangeSetting) {
                // replace old if there's old (need nil check only if never init to empty array)
                [self.mapView removeAnnotations:change[NSKeyValueChangeOldKey]];
                // set new
                [self.mapView addAnnotations:change[NSKeyValueChangeNewKey]];
            }
        } // end else if keyPath is @"savedSpotsBeingShown"
        
        // saved spots (region monitoring)
        else if ([keyPath isEqualToString:NSStringFromSelector(@selector(savedSpots))]) {
            NSKeyValueChange kindOfChange = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
            if (kindOfChange == NSKeyValueChangeSetting || // may separate out later for efficiency
                kindOfChange == NSKeyValueChangeInsertion) { // also later just add region for insert
                // if no user location, wait til user location available
                [self refreshSpotsForRegionMonitoring]; // for now, if no location, will be ignored
            }
        } // end else if keyPath is @"savedSpots"
    } // end if object is [DataSource sharedInstance]
}


#pragma mark - Callout VC delegate

- (void) didPressDirectionsButton {
    MKPlacemark* spotPlacemark = [[MKPlacemark alloc] initWithCoordinate:self.currentSelectedSpot.coordinate addressDictionary:self.currentSelectedSpot.addressDictionary];
    MKMapItem* spotItem = [[MKMapItem alloc] initWithPlacemark:spotPlacemark];
    
    // passing one item gives direction from current location (2 items is directions between them)
    [MKMapItem openMapsWithItems:@[spotItem] launchOptions:@{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving}];
    
    // overtaking this method to test region monitoring methods
//    [self removeAllSpotsForRegionMonitoring];
//    [self addSpotsForRegionMonitoring];
}


#pragma mark - CoinSide protocol methods

- (NSString*) buttonName {
    return NSLocalizedString(@"Map", @"Map button");
}

- (UIImage*) buttonImage {
    return [UIImage imageNamed:@"map"];
}


#pragma mark - Map View methods

- (MKCoordinateRegion) currentRegion {
    return self.mapView.region;
}


#pragma mark - Map View delegate

// map delegate for adding annotations
- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // adopted from Apple docs: provide pins
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil; // if annotation is user location, return nil
    }
    
    static NSString* identifier = @"myAnnotationView";
    
    MKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!annotationView) {
        annotationView = [[AnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.canShowCallout = NO;
    } else { // reuse existing AV
        annotationView.annotation = annotation;
    }
    
    Spot* spotAnnotation = (Spot*)annotation;
    if (spotAnnotation.saved) {
        annotationView.image = [UIImage imageNamed:@"spotSaved"];
    } else {
        annotationView.image = [UIImage imageNamed:@"spotSearched"];
    }
    
    return annotationView;
}

- (void) mapView:(MKMapView*)mapView didSelectAnnotationView:(MKAnnotationView*)view {
    // runtime error occurs if tap on user location
    if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
        return;
    }
    
    // if a previous annotation was selected before this, save the notes (and the spot)
    [self saveNotes];
    
    
    //self.currentAnnotationView = view;
    self.currentSelectedSpot = (Spot*)view.annotation;
    
    // i wonder what this does exactly ...
    //[mapView deselectAnnotation:view.annotation animated:YES];
    
    if (!self.calloutViewController) { // 1. init VC
        self.calloutViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"callout2"];
        self.calloutViewController.delegate = self;
    }
    self.calloutViewController.spot = (Spot*)view.annotation; // 2. attributes
    [self addChildViewController:self.calloutViewController]; // 3. addChildVC
    
    // safe alternative: add to map view
    [mapView addSubview:self.calloutViewController.view]; // 4. addSubview
    CGFloat width = 250, height = 200;
    CGFloat x = (CGRectGetWidth(self.mapView.bounds) - width) / 2;
    CGFloat y = 20;
    self.calloutViewController.view.frame = CGRectMake(x, y, width, height); // 5. position
    
    // better alternative: add to AV
//    [view addSubview:self.calloutViewController.view]; // 4. addSubview
//    self.calloutViewController.view.frame = CGRectMake(0, 0, 250, 200); // 5. position

    // using PresentationController didn't work probably because should follow the delegate protocol
    
    // popovers might still work, but don't technically work on mobile (just tablet)
}

- (void) mapView:(MKMapView*)mapView didDeselectAnnotationView:(MKAnnotationView*)view {
    // if a previous annotation was selected before this, save the notes (and the spot)
    [self saveNotes];

    //self.currentAnnotationView = nil;
    self.currentSelectedSpot = nil;
    
    // remove calloutVC
    [self.calloutViewController.view removeFromSuperview];
    [self.calloutViewController removeFromParentViewController];
}

// only save if there's a currentSelectedSpot and the textView contains different text
- (void) saveNotes {
    if (self.currentSelectedSpot) {
        NSString* textViewText = self.calloutViewController.descriptionTextView.text;
        if (![self.currentSelectedSpot.notes isEqualToString: textViewText]) {
            // KVO on Spots too?
            self.currentSelectedSpot.notes = textViewText;
            
            // should not be adding another spot (just do normal archive)
            [[DataSource sharedInstance] archiveSavedSpots];
        }
    }
}


#pragma mark - Nearby Notifications

// best to use just this method (don't call AddSpotsFRM or removeSpotsFRM elsewhere)
- (void) refreshSpotsForRegionMonitoring {
    if (self.locationManager.location) {
        [self removeAllSpotsForRegionMonitoring];
        [self addSpotsForRegionMonitoring];
    }
}

- (void) addSpotsForRegionMonitoring {
    // sort savedSpots by distance away
    NSArray* savedSpotsSorted = [[DataSource sharedInstance] sortSavedSpots:self.locationManager.location];
    
    // (might the location at this point be different than the location(s) used in the loop below?)
    
    // only add top 20 (at most 20) that are less than 30 miles
    for (int i = 0; i < MIN(20, savedSpotsSorted.count); i++) {
        // if spot is less than 30 miles away, add region
        Spot* spot = savedSpotsSorted[i];
        CLLocation* location = [[CLLocation alloc] initWithLatitude:spot.coordinate.latitude longitude:spot.coordinate.longitude];
        CLLocationDistance metersDistance = [self.locationManager.location distanceFromLocation:location];
        CLLocationDistance milesDistance = metersDistance / 1609.344;
        
        // be selective once debugged
//        if (milesDistance > 30) {
//            break;
//        }
        
        // region is a 30-mile radius around spot (48280.32 m = 30 mi * 1609.344 m/mi)
        // testing using 4000 (~3 mi)
        NSString* identifier = [self encodeRegionIDWithTitle:spot.title coordinate:spot.coordinate];
        CLCircularRegion* region = [[CLCircularRegion alloc] initWithCenter:spot.coordinate radius:700 identifier:identifier];//[spot.title stringByAppendingFormat:@"%f%f", spot.coordinate.latitude, spot.coordinate.longitude]];
        //region.notifyOnExit = NO; // don't care about exiting
        
        // technically, should set the radius of the region to MIN(radius, self.locMgr.maxRegMonDist)
        [self.locationManager startMonitoringForRegion:region];
    }
}

- (void) removeAllSpotsForRegionMonitoring {
    // go through each region key and remove from monitoring (may cause concurrent error)
    [self.locationManager.monitoredRegions enumerateObjectsUsingBlock:^(__kindof CLRegion*_Nonnull obj, BOOL*_Nonnull stop) {
        [self.locationManager stopMonitoringForRegion:obj];
    }];
}

// encode region ID
- (NSString*) encodeRegionIDWithTitle:(NSString*)title coordinate:(CLLocationCoordinate2D)coordinate {
    return [title stringByAppendingFormat:@" %f %f", coordinate.latitude, coordinate.longitude];
}

- (NSString*) decodeTitleFromRegionID:(NSString*)regionID {
    NSRange rangeOfLastDelimiter = [regionID rangeOfString:@" " options:NSBackwardsSearch];
    NSRange rangeOfRegionIDBeforeLastDelimiter = NSMakeRange(0, rangeOfLastDelimiter.location);
    NSRange rangeOfSecondToLastDelimiter = [regionID rangeOfString:@" " options:NSBackwardsSearch range:rangeOfRegionIDBeforeLastDelimiter]; // base case checks "s 2 4" " 1 3"
    return [regionID substringToIndex:rangeOfSecondToLastDelimiter.location];
}

#pragma mark - CLLocationManager delegate

// seems to get called on startup each time
- (void) locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"Did change authorization status");
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.showsUserLocation = YES;
        [self.locationManager startUpdatingLocation];
    }
}

- (void) locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray<CLLocation*> *)locations {
    NSLog(@"Did update location with %ld size array last item: %@", locations.count, [locations lastObject]);
    
    // only load regions once
    //NSLog(@"pre stop locMgr.location: %@", manager.location);
    [self refreshSpotsForRegionMonitoring];
    [manager stopUpdatingLocation];
    //[manager stopMonitoringSignificantLocationChanges];
    //NSLog(@"post stop locMgr.location: %@", manager.location);
}

- (void) locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion*)region {
    NSLog(@"Entering region: %@", region.identifier);
    
    // instantiate notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    
    //localNotification.regionTriggersOnce = YES; // this is default
    
    // setting region here is wrong. at this point, notification needs to fire immediately since we just entered a region. setting a region now will delay notification til the next region event (which will be an exit)
    //localNotification.region = region;
    
    // these fields not shown in lock screen or top notification bar
    //localNotification.alertAction = @"Go! Go! Go!";
    //localNotification.alertTitle = NSLocalizedString(@"Nearing Spot!", @"alert notification title");
    //localNotification.alertLaunchImage = @"second";

    NSString* alertDetails = [NSString stringWithFormat:@"You are about a half mile away from %@", [ self decodeTitleFromRegionID:region.identifier]];
    localNotification.alertBody = NSLocalizedString(alertDetails, @"alert notification details");
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

// don't care about exiting region (or anything other than entering)

// this method should be called if too many regions added, or something related to that
//- (void) locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
//    NSLog(@"Monitoring failed for region: %@ with error: %@", region, error);
//}

//- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
//    NSLog(@"Did start monitoring for region: %@", region);
//}

@end

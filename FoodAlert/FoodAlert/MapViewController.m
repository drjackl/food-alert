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

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, CategorySelectViewControllerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView* mapView;

@property (nonatomic) CLLocationManager* locationManager;

@property (nonatomic) CategorySelectViewController* categorySelectModal;

@property (nonatomic) Spot* currentSelectedSpot;
@property (nonatomic) MKAnnotationView* currentAnnotationView;

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
            self.locationManager = [CLLocationManager new];
            self.locationManager.delegate = self;
//        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager requestWhenInUseAuthorization]; // needed post iOS 8
//        case kCLAuthorizationStatusAuthorizedWhenInUse:
            //[self.locationManager startUpdatingLocation];
//    }
    
    
    
    self.mapView.showsUserLocation = YES; // done in storyboard now
    
    
    [[DataSource sharedInstance] addObserver:self forKeyPath:NSStringFromSelector(@selector(currentSearchedSpots)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [[DataSource sharedInstance] addObserver:self forKeyPath:NSStringFromSelector(@selector(savedSpotsBeingShown)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [[DataSource sharedInstance] removeObserver:self forKeyPath:NSStringFromSelector(@selector(currentSearchedSpots))];
    [[DataSource sharedInstance] removeObserver:self forKeyPath:NSStringFromSelector(@selector(savedSpotsBeingShown))];
}

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
        
        else if ([keyPath isEqualToString:NSStringFromSelector(@selector(savedSpotsBeingShown))]) {
            NSKeyValueChange kindOfChange = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
            if (kindOfChange == NSKeyValueChangeSetting) {
                // replace old if there's old (need NULL check only if never init to empty array)
                //if ([change[NSKeyValueChangeOldKey] isKindOfClass:[NSArray class]]) {
                    [self.mapView removeAnnotations:change[NSKeyValueChangeOldKey]];
                //}
                // set new
                [self.mapView addAnnotations:change[NSKeyValueChangeNewKey]];
            }
        }
        
    }
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

- (void) addSpots:(NSArray*)spotsArray {
    [self.mapView addAnnotations:spotsArray];
}

#pragma mark - Map View delegate methods

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
    if (self.currentSelectedSpot) {
        // KVO on Spots too?
        self.currentSelectedSpot.notes = self.calloutViewController.descriptionTextView.text;
        
        //[[DataSource sharedInstance] saveSpot:self.currentSelectedSpot];
        // should not be adding another spot (just do normal save)
        [[DataSource sharedInstance] archiveSavedSpots];
    }
    
    
    self.currentAnnotationView = view;
    self.currentSelectedSpot = (Spot*)view.annotation;
    
    // i wonder what this does exactly ...
    //[mapView deselectAnnotation:view.annotation animated:YES];
    
    if (!self.calloutViewController) { // 1. init VC
        self.calloutViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"callout2"];
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
    if (self.currentSelectedSpot) {
        // KVO on Spots too?
        self.currentSelectedSpot.notes = self.calloutViewController.descriptionTextView.text;
        
        //[[DataSource sharedInstance] saveSpot:self.currentSelectedSpot];
        // should not be adding another spot (just do normal save)
        [[DataSource sharedInstance] archiveSavedSpots];
    }

    self.currentAnnotationView = nil;
    self.currentSelectedSpot = nil;
    
    // remove calloutVC
    [self.calloutViewController.view removeFromSuperview];
    [self.calloutViewController removeFromParentViewController];
}


#pragma mark - Category Select Modal delegate

// was implemented for custom MKAV and standard callout (category was right accessory view)
- (void) didSelectCategory:(Categorie *)category {
    self.currentSelectedSpot.category = category;
    //[self updateCategoryButtonOfAnnotationView:self.currentAnnotationView]; // default callouts
    
    // somehow, these aren't saving ... or are they now ...
    [[DataSource sharedInstance] archiveCategories];
    [[DataSource sharedInstance] archiveSavedSpots];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"categorySelect"]) {
        self.categorySelectModal = (CategorySelectViewController*)segue.destinationViewController;
        self.categorySelectModal.delegate = self;
    }
}


@end

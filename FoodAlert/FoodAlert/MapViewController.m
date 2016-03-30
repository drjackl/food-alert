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
#import "Spot.h"
#import "DataSource.h"
#import "CategorySelectViewController.h"
#import "CalloutViewController.h"
#import "CategoryPresentationController.h"

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, CategorySelectViewControllerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView* mapView;
@property (nonatomic) CategorySelectViewController* categorySelectModal;

@property (nonatomic) CLLocationManager* locationManager;

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
    
    // handle Spot annotations
    if ([annotation isKindOfClass:[Spot class]]) {
        // try to dequeue an existing pin first (maybe don't need check if new one created)
        MKAnnotationView* spotAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"spotSimpleShapeAnnotationView"];
        
        if (!spotAnnotationView) { // if existing pin not available, create one (maybe don't need to create new one)
            spotAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"spotSimpleShapeAnnotationView"];
            //spotAnnotationView.canShowCallout = YES; // for custom image MKAV
            spotAnnotationView.canShowCallout = NO; // for own callout
            
            spotAnnotationView.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
            
            UIButton* categoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
            //[categoryButton setTitle:NSLocalizedString(@"<category>", @"default category") forState:UIControlStateNormal]; // refactored out to updateCatButton
            [categoryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //categoryButton.backgroundColor = [UIColor redColor]; // refactored out to updateCatButton
            categoryButton.userInteractionEnabled = YES;
            categoryButton.frame = CGRectMake(0, 0, 200, 20);
            spotAnnotationView.rightCalloutAccessoryView = categoryButton;
        } else { // reuse existing pin
            spotAnnotationView.annotation = annotation;
        }
        
        [self updateCategoryButtonOfAnnotationView:spotAnnotationView];
        
        
        Spot* recastedSpotAnnotation = (Spot*)annotation;
        if (recastedSpotAnnotation.saved) {
            //spotAnnotationView.pinTintColor = [UIColor yellowColor]; // specific to MKPinAV
            spotAnnotationView.image = [UIImage imageNamed:@"spotSaved"];
        } else {
            //spotAnnotationView.pinTintColor = [UIColor blueColor]; // specific to MKPinAV
            spotAnnotationView.image = [UIImage imageNamed:@"spotSearched"];
        }
        
        return spotAnnotationView;
    }
    
    return nil;
}

// custom image MKAV: save spot if + button tapped, select category if right button selected
// probably not needed once custom callout in place
- (void) mapView:(MKMapView*)mapView annotationView:(MKAnnotationView*)view calloutAccessoryControlTapped:(UIControl*)control {
    if ([control isKindOfClass:[UIButton class]]) {
        UIButton* buttonControl = (UIButton*)control;
        if (buttonControl.buttonType == UIButtonTypeContactAdd) {
            [self saveSpot:(Spot*)view.annotation];
        } else if (buttonControl.buttonType == UIButtonTypeCustom) {
            // is there a better way than storing this as a property?
            self.currentSelectedSpot = (Spot*)view.annotation;
            self.currentAnnotationView = view;
            // bring up select category dialog
            [self performSegueWithIdentifier:@"categorySelect" sender:self];
        }
    }
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
    
    //[mapView deselectAnnotation:view.annotation animated:YES];
    
    if (!self.calloutViewController) { // 1. init VC
        self.calloutViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"callout2"];
    }
    self.calloutViewController.spot = (Spot*)view.annotation; // 2. attributes
    [self addChildViewController:self.calloutViewController]; // 3. addChildVC
    [mapView addSubview:self.calloutViewController.view]; // 4. addSubview
    self.calloutViewController.view.frame = CGRectMake(100, 150, 250, 200); // 5. position

    
    //CategoryPresentationController* categoryPC = [[CategoryPresentationController alloc] initWithPresentedViewController:self presentingViewController:calloutViewController];
    
    //UIPopoverController* popoverController = [[UIPopoverController alloc] initWithContentViewController:calloutViewController];
    //[popoverController presentPopoverFromRect:view.frame inView:view.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
//    [mapView addSubview:calloutViewController.view];
//    calloutViewController.view.frame = CGRectMake(100, 300, 300, 300);
    
    //[categoryPC present];
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

// refactored to DataSource, probably not needed anymore
- (void) saveSpot:(Spot*)spot {
    [[DataSource sharedInstance] saveSpot:spot];
}

- (void) updateCategoryButtonOfAnnotationView:(MKAnnotationView*)annotationView {
    Categorie* category = ((Spot*)annotationView.annotation).category;
    if (category) {
        annotationView.rightCalloutAccessoryView.backgroundColor = category.color;
        [((UIButton*)annotationView.rightCalloutAccessoryView) setTitle:category.title forState:UIControlStateNormal];
    } else {
        annotationView.rightCalloutAccessoryView.backgroundColor = [UIColor redColor];
        [((UIButton*)annotationView.rightCalloutAccessoryView) setTitle:NSLocalizedString(@"<category>", @"default category") forState:UIControlStateNormal];
    }
}

#pragma mark - Category Select Modal delegate

// was implemented for custom MKAV and standard callout (category was right accessory view)
- (void) didSelectCategory:(Categorie *)category {
    self.currentSelectedSpot.category = category;
    [self updateCategoryButtonOfAnnotationView:self.currentAnnotationView];
    
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

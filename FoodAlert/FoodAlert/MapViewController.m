//
//  MapViewController.m
//  FoodAlert
//
//  Created by Jack Li on 3/12/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "Spot.h"
#import "DataSource.h"
#import "CategorySelectViewController.h"

@interface MapViewController () <MKMapViewDelegate, CategorySelectViewControllerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView* mapView;
@property (nonatomic) CategorySelectViewController* categorySelectModal;

@property (nonatomic) Spot* currentSelectedSpot;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.savedSpots = [NSMutableArray new];
    
    self.mapView.delegate = self;
    
    // load savedSpots from archive
    //[[DataSource sharedInstance] unarchiveSavedSpots]; // i think this should happen in DataSource init; yes, instead i should be registering for observation here
    //[self addSpots:self.savedSpots]; this is still empty by the time called (since unarchive doesn't guarantee immediate unpackaging)
    
    [[DataSource sharedInstance] addObserver:self forKeyPath:NSStringFromSelector(@selector(currentSearchedSpots)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [[DataSource sharedInstance] removeObserver:self forKeyPath:NSStringFromSelector(@selector(currentSearchedSpots))];
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary<NSString*,id>*)change context:(void*)context {
    if (object == [DataSource sharedInstance] && [keyPath isEqualToString:NSStringFromSelector(@selector(currentSearchedSpots))]) {
        NSKeyValueChange kindOfChange = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
        if (kindOfChange == NSKeyValueChangeSetting) {
            // replace old if there's old
            [self.mapView removeAnnotations:change[NSKeyValueChangeOldKey]];
            // set new
            [self.mapView addAnnotations:change[NSKeyValueChangeNewKey]];
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
        //MKPinAnnotationView* spotAnnotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"spotPinAnnotationView"];
        MKAnnotationView* spotAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"spotSimpleShapeAnnotationView"];
        
        if (!spotAnnotationView) { // if existing pin not available, create one (maybe don't need to create new one)
            spotAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"spotSimpleShapeAnnotationView"];
            //spotAnnotationView.animatesDrop = YES; // specific to MKPinAV
            spotAnnotationView.canShowCallout = YES;
            
            spotAnnotationView.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
            //spotAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoDark];
            //spotAnnotationView.detailCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            //[saveButton addTarget:self action:@selector(saveSpot:) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton* categoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [categoryButton setTitle:NSLocalizedString(@"<category>", @"default category") forState:UIControlStateNormal];
            [categoryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //categoryButton.backgroundColor = [UIColor redColor];
            categoryButton.userInteractionEnabled = YES;
            categoryButton.frame = CGRectMake(0, 0, 200, 20);
            spotAnnotationView.rightCalloutAccessoryView = categoryButton;
        } else { // reuse existing pin
            spotAnnotationView.annotation = annotation;
        }
        
        Categorie* category = ((Spot*)spotAnnotationView.annotation).category;
        spotAnnotationView.rightCalloutAccessoryView.backgroundColor = category ? category.color : [UIColor redColor];
        
        if ([annotation isKindOfClass:[Spot class]]) {
            Spot* recastedSpotAnnotation = (Spot*)annotation;
            if (recastedSpotAnnotation.saved) {
                //spotAnnotationView.pinTintColor = [UIColor yellowColor]; // specific to MKPinAV
                spotAnnotationView.image = [UIImage imageNamed:@"spotSaved"];
            } else {
                //spotAnnotationView.pinTintColor = [UIColor blueColor]; // specific to MKPinAV
                spotAnnotationView.image = [UIImage imageNamed:@"spotSearched"];
            }
        }
        
        return spotAnnotationView;
    }
    
    return nil;
}

- (void) mapView:(MKMapView*)mapView annotationView:(MKAnnotationView*)view calloutAccessoryControlTapped:(UIControl*)control {
    if ([control isKindOfClass:[UIButton class]]) {
        UIButton* buttonControl = (UIButton*)control;
        if (buttonControl.buttonType == UIButtonTypeContactAdd) {
            [self saveSpot:(Spot*)view.annotation];
        } else if (buttonControl.buttonType == UIButtonTypeCustom) {
            // is there a better way than storing this as a property?
            self.currentSelectedSpot = (Spot*)view.annotation;
            // bring up select category dialog
            [self performSegueWithIdentifier:@"categorySelect" sender:self];
        }
    }
}

- (void) saveSpot:(Spot*)spot {
    spot.saved = YES;
    [[DataSource sharedInstance].savedSpots addObject:spot];
    
    [[DataSource sharedInstance] archiveSavedSpots];
}

#pragma mark - Category Select Modal delegate

- (void) didSelectCategory:(Categorie *)category {
    self.currentSelectedSpot.category = category;
    
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

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

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView* mapView;
//@property (nonatomic) NSMutableArray* savedSpots; // put in model later
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.savedSpots = [NSMutableArray new];
    
    self.mapView.delegate = self;
    
    // load savedSpots from archive
    //[[DataSource sharedInstance] unarchiveSavedSpots]; // i think this should happen in DataSource init; yes, instead i should be registering for observation here
    //[self addSpots:self.savedSpots]; this is still empty by the time called
    
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

#pragma mark - mapView methods

- (MKCoordinateRegion) currentRegion {
    return self.mapView.region;
}

- (void) addSpots:(NSArray*)spotsArray {
    [self.mapView addAnnotations:spotsArray];
}

#pragma mark - mapView delegate methods

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
            
            UIButton* saveButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
            spotAnnotationView.leftCalloutAccessoryView = saveButton;
            //[saveButton addTarget:self action:@selector(saveSpot:) forControlEvents:UIControlEventTouchUpInside];
        } else { // reuse existing pin
            spotAnnotationView.annotation = annotation;
        }
        
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
    [self saveSpot:(Spot*)view.annotation];
}

- (void) saveSpot:(Spot*)spot {
    spot.saved = YES;
    [[DataSource sharedInstance].savedSpots addObject:spot];
    
    [[DataSource sharedInstance] archiveSavedSpots];
}

//- (void) archiveSavedSpots {
//    // based off blocstagram
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSString* fullPath = [self pathForSavedSpots];
//        NSData* savedSpotsToStore = [NSKeyedArchiver archivedDataWithRootObject:self.savedSpots];
//        NSError* dataError;
//        
//        BOOL wroteSuccessfully = [savedSpotsToStore writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
//        
//        if (!wroteSuccessfully) {
//            NSLog(@"Couldn't write file: %@", dataError);
//        }
//    });
//}

//- (void) unarchiveSavedSpots {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSString* fullPath = [self pathForSavedSpots];
//        
//        NSArray* savedSpotsToLoad = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
//        
//        // maybe i don't need this since i'm not downloading blocstagram images?
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSMutableArray* mutableSavedSpots = [savedSpotsToLoad mutableCopy];
//            self.savedSpots = mutableSavedSpots;
//            
//            [self addSpots:self.savedSpots];
//        });
//    });
//}

//- (NSString*) pathForSavedSpots {
//    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
//    NSString* directory = [paths firstObject];
//    NSString* dataPath = [directory stringByAppendingString:NSStringFromSelector(@selector(savedSpots))];
//    return dataPath;
//}

//- (void) saveSpot:(UIButton*)sender {
//    
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

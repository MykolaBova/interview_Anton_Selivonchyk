//
//  PFSearchController.m
//  PlaceFinder
//
//  Created by Anton on 5/12/20.
//  Copyright © 2020 Anton. All rights reserved.
//

#import "PFSearchController.h"
#import "PFNetworking.h"
#import "PFPlace.h"

@interface PFSearchController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField* cityTextField;

@property (assign, nonatomic) CLLocationCoordinate2D searchCoordinate;
@property (strong, nonatomic) CLLocationManager* locationManager;

@end

@implementation PFSearchController

- (void)setSearchCoordinate:(CLLocationCoordinate2D)searchCoordinate {
    if (searchCoordinate.longitude == _searchCoordinate.longitude && searchCoordinate.latitude == _searchCoordinate.latitude) {
        return;
    }

    _searchCoordinate = searchCoordinate;

    [self loadPlaces];
}

#pragma mark - IBActions

- (IBAction)searchTextAction:(id)sender {
    [self loadCity];
}

- (IBAction)searchNearestAction:(id)sender {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (IBAction)skipAction:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate interface

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation*>*)locations {
    CLLocationCoordinate2D coordinate = [locations firstObject].coordinate;
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        self.searchCoordinate = coordinate;
    }
}

#pragma mark - Private interface

- (void)loadCity {
    __weak typeof(self) weakSelf = self;
    [PFNetworking requestCityCoordinates:self.cityTextField.text completion:^(CLLocationCoordinate2D coordinate, NSString * _Nullable errorString) {
        if (errorString != nil) {
            [weakSelf displayErrorString:errorString];
        } else {
            weakSelf.searchCoordinate = coordinate;
        }
    }];
}

- (void)loadPlaces {
    __weak typeof(self) weakSelf = self;
    [PFNetworking requestPlacesFor:self.searchCoordinate completion:^(NSArray<NSDictionary *> * _Nullable results, NSString * _Nullable errorString) {
        if (errorString != nil) {
            [weakSelf displayErrorString:errorString];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSDictionary* result in results) {
                    [PFPlace loadFromDictionary:result];
                }

                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
        }
    }];
}

- (void)displayErrorString:(NSString*)errorString {
    dispatch_block_t displayBlock = ^{
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Error" message:errorString preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
    };

    if ([NSThread isMainThread]) {
        displayBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), displayBlock);
    }
}

@end

//
//  PFSearchController.m
//  PlaceFinder
//
//  Created by Anton on 5/12/20.
//  Copyright © 2020 Anton. All rights reserved.
//

#import "PFSearchController.h"
#import <CoreLocation/CoreLocation.h>
#import "PFPlace.h"

//NSString* const apiKey = @"AIzaSyCCOAaGJlvgPhCRB1-ppj9vW2kq9hwQKNg";
NSString* const apiKey = @"AIzaSyBPsziH_ZUzf6dty3UGMGXE2_hli___MIA";
NSString* const cityURLFormat = @"https://maps.googleapis.com/maps/api/place/textsearch/json?query=%@&key=%@";
NSString* const locationURLFormat = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%.7f,%.7f&radius=5000&key=%@";

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
    NSLog(@"setSearchCoordinate(lat: %@ lon: %@)", @(searchCoordinate.latitude), @(searchCoordinate.longitude));

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
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    NSString* cityName = self.cityTextField.text;

    if (cityName == nil || [cityName isEqualToString:@""]) {
        [self displayErrorString:@"Empty city name"];
        return;
    }

    NSString* cityURLString = [NSString stringWithFormat:cityURLFormat, cityName, apiKey];

    [request setURL:[NSURL URLWithString:cityURLString]];
    [request setHTTPMethod:@"GET"];
    [request addValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"text/plain" forHTTPHeaderField:@"Accept"];

    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    __weak typeof(self) weakSelf = self;
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString* requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSData* responseData = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];

        NSLog(@"requestReply: %@ error: %@", jsonDict, error.localizedDescription);
        if (error != nil) {
            [weakSelf displayErrorString:error.localizedDescription];
        } else {
            NSString* status = [jsonDict objectForKey:@"status"];
            if ([status isEqualToString:@"OK"]) {
                NSString* latitudeString = [[jsonDict valueForKeyPath:@"results.geometry.location.lat"] firstObject];
                NSString* longitudeString = [[jsonDict valueForKeyPath:@"results.geometry.location.lng"] firstObject];

                weakSelf.searchCoordinate = CLLocationCoordinate2DMake(latitudeString.doubleValue, longitudeString.doubleValue);

            } else {
                NSString* errorMessage = [jsonDict objectForKey:@"error_message"];
                if (errorMessage == nil) {
                    errorMessage = [NSString stringWithFormat:@"Can't find city \"%@\"", cityName];
                }

                [weakSelf displayErrorString:errorMessage];
            }
        }

    }] resume];
}

- (void)loadPlaces {
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    NSString* locationURLString = [NSString stringWithFormat:locationURLFormat, self.searchCoordinate.latitude, self.searchCoordinate.longitude, apiKey];

    [request setURL:[NSURL URLWithString:locationURLString]];
    [request setHTTPMethod:@"GET"];
    [request addValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"text/plain" forHTTPHeaderField:@"Accept"];

    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    __weak typeof(self) weakSelf = self;
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString* requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSData* responseData = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];

        NSLog(@"requestReply: %@ error: %@", jsonDict, error.localizedDescription);
        if (error != nil) {
            [weakSelf displayErrorString:error.localizedDescription];
        } else {
            NSString* status = [jsonDict objectForKey:@"status"];
            if ([status isEqualToString:@"OK"]) {


                NSArray<NSDictionary*>* results = [jsonDict objectForKey:@"results"];
                for (NSDictionary* result in results) {
                    NSLog(@"result: %@", result);

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [PFPlace loadFromDictionary:result];
                    });
                }

            } else {
                [weakSelf displayErrorString:[jsonDict objectForKey:@"error_message"]];
            }
        }

    }] resume];
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

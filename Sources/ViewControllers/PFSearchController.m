//
//  PFSearchController.m
//  PlaceFinder
//
//  Created by Anton on 5/12/20.
//  Copyright © 2020 Anton. All rights reserved.
//

#import "PFSearchController.h"

@interface PFSearchController ()


@end

@implementation PFSearchController

#pragma mark - IBActions

- (IBAction)searchTextAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)searchNearestAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

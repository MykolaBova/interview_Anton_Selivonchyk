//
//  PFNavigationController.m
//  PlaceFinder
//
//  Created by Anton on 5/12/20.
//  Copyright © 2020 Anton. All rights reserved.
//

#import "PFNavigationController.h"
#import "PFSearchController.h"

@interface PFNavigationController ()

@property (assign, nonatomic) BOOL didShowSearch;

@end

@implementation PFNavigationController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.didShowSearch == NO) {
        self.didShowSearch = YES;

        [self showSearchController:NO];
    }
}

- (void)showSearchController:(BOOL)animated {
    PFSearchController* _Nonnull searchController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PFSearchController class])];

    [self presentViewController:searchController animated:animated completion:nil];
}

@end

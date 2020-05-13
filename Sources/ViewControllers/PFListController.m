//
//  PFListController.m
//  PlaceFinder
//
//  Created by Anton on 5/12/20.
//  Copyright © 2020 Anton. All rights reserved.
//

#import "PFListController.h"
#import <UIKit/UIKit.h>
#import "PFPlace.h"
#import "PFDetailsController.h"

NSString* const kListCellIdentifier = @"listCellIdentifier";
NSString* const kShowDetailSegueIdentifier = @"kShowDetailSegueIdentifier";

@interface PFListController () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl* filterSegmentedControl;

@property (strong, nonatomic) NSArray<PFPlace*>* places;
@property (strong, nonatomic) RLMNotificationToken* notificationToken;
@property (strong, nonatomic) NSArray<NSString*>* filters;

@end

@implementation PFListController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.filters = [PFPlace filters];
    [self reloadData];

    RLMRealm* realm = [RLMRealm defaultRealm];
    __weak typeof(self) weakSelf = self;
    self.notificationToken = [realm addNotificationBlock:^(RLMNotification  _Nonnull notification, RLMRealm * _Nonnull realm) {
        [weakSelf reloadData];
    }];
}

- (void)setFilters:(NSArray<NSString*>*)filters {
    _filters = [@[@"All"] arrayByAddingObjectsFromArray:filters];

    [_filterSegmentedControl removeAllSegments];
    for (NSString* filter in _filters) {
        [_filterSegmentedControl insertSegmentWithTitle:filter atIndex:_filterSegmentedControl.numberOfSegments animated:NO];
    }

    _filterSegmentedControl.selectedSegmentIndex = 0;
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kShowDetailSegueIdentifier]) {

        PFDetailsController* detailsController = (PFDetailsController*)[segue destinationViewController];
        UITableViewCell* selectedCell = (UITableViewCell*)sender;
        NSIndexPath* indexPath = [self.tableView indexPathForCell:selectedCell];

        detailsController.placeID = self.places[indexPath.row].placeID;
    }
}

#pragma mark - UITableViewDelegate interface

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return self.places.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kListCellIdentifier];
    PFPlace* place = self.places[indexPath.row];

    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", place.name, place.placeID];
    return cell;
}

#pragma mark - IBActions

- (IBAction)applyFilterAction:(UISegmentedControl*)sender {
    [self reloadData];
}

#pragma mark - Private interface

- (void)reloadData {
    NSMutableArray<PFPlace*>* places = [NSMutableArray array];
    if (self.filterSegmentedControl.selectedSegmentIndex == 0) {
        for (PFPlace* place in [PFPlace allObjects]) {
            [places addObject:place];
        }
    } else {
        NSString* filterString = self.filters[self.filterSegmentedControl.selectedSegmentIndex];
        for (PFPlace* place in [PFPlace allObjects]) {
            for (NSString* type in place.types) {
                if ([type isEqualToString:filterString]) {
                    [places addObject:place];
                }
            }
        }
    }
    self.places = places;

    [self.tableView reloadData];
}

@end

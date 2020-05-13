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

NSString* const kListCellIdentifier = @"listCellIdentifier";

@interface PFListController () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView* tableView;

@property (strong, nonatomic) RLMResults<PFPlace*>* places;
@property (strong, nonatomic) RLMNotificationToken* notificationToken;

@end

@implementation PFListController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.places = [PFPlace allObjects];

    RLMRealm* realm = [RLMRealm defaultRealm];
    __weak typeof(self) weakSelf = self;
    self.notificationToken = [realm addNotificationBlock:^(RLMNotification  _Nonnull notification, RLMRealm * _Nonnull realm) {
        weakSelf.places = [PFPlace allObjects];
        [weakSelf.tableView reloadData];
    }];
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

@end

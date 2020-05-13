//
//  PFDetailsController.m
//  PlaceFinder
//
//  Created by Anton on 5/12/20.
//  Copyright © 2020 Anton. All rights reserved.
//

#import "PFDetailsController.h"
#import "PFPlace.h"
#import "PFNetworking.h"

@interface PFDetailsController ()

@property (weak, nonatomic) IBOutlet UIImageView* imageView;
@property (weak, nonatomic) IBOutlet UILabel* idLabel;
@property (weak, nonatomic) IBOutlet UILabel* locationLabel;
@property (weak, nonatomic) IBOutlet UITextField* nameTextField;
@property (weak, nonatomic) IBOutlet UILabel* typesLabel;

@property (strong, nonatomic) PFPlace* place;

@end

@implementation PFDetailsController

- (void)setPlaceID:(NSString*)placeID {
    if ([placeID isEqualToString:_placeID]) {
        return;
    }

    _placeID = placeID;
    self.place = [PFPlace objectForPrimaryKey:_placeID];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    __weak typeof(self) weakSelf = self;
    [PFNetworking requestImageWith:self.place.photoReference completion:^(UIImage * _Nullable image) {
        weakSelf.imageView.image = image;
    }];

    self.idLabel.text = self.place.placeID;
    self.nameTextField.text = self.place.name;
    self.typesLabel.text = [self.place typesString];
    self.locationLabel.text = [self.place locationString];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self save];
}

#pragma mark - IBActions

- (IBAction)saveAction:(UIBarButtonItem *)sender {
    [self save];
}

#pragma mark - Private interface

- (void)save {
    NSString* name = self.nameTextField.text;
    if (name == nil || [name isEqualToString:self.place.name]) { // just so the place always has a name
        return;
    }

    RLMRealm* realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];

    self.place.name = name;
    self.place.wasEdited = YES;

    [realm commitWriteTransaction];
}

@end

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
@property (weak, nonatomic) IBOutlet UITextField* phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField* addressTextField;
@property (weak, nonatomic) IBOutlet UITextField* ratingTextField;

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

    [self reloadTextValues];

    if (self.place.wasEdited == NO) {
        [PFNetworking requestDetailsFor:self.place.placeID completion:^(NSDictionary * _Nullable details) {
            [weakSelf.place detailsFromDictionary:details];
            [weakSelf reloadTextValues];
        }];
    }
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

    // just so the place always has a name
    if (name == nil) {
        return;
    }

    BOOL nothingToSave = [name isEqualToString:self.place.name] && [self.phoneTextField.text isEqualToString:self.place.phoneNumber] && [self.addressTextField.text isEqualToString:self.place.address] && [self.ratingTextField.text isEqualToString:self.place.rating];
    if (nothingToSave == YES) {
        return;
    }

    RLMRealm* realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];

    self.place.name = name;
    self.place.phoneNumber = self.phoneTextField.text;
    self.place.address = self.addressTextField.text;
    self.place.rating = self.ratingTextField.text;
    self.place.wasEdited = YES;

    [realm commitWriteTransaction];
}

- (void)reloadTextValues {
    self.idLabel.text = self.place.placeID;
    self.nameTextField.text = self.place.name;
    self.typesLabel.text = [self.place typesString];
    self.locationLabel.text = [self.place locationString];

    self.phoneTextField.text = self.place.phoneNumber;
    self.addressTextField.text = self.place.address;
    self.ratingTextField.text = self.place.rating;
}

@end

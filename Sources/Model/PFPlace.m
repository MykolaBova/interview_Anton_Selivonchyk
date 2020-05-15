//
//  PFPlace.m
//  PlaceFinder
//
//  Created by Anton on 5/12/20.
//  Copyright © 2020 Anton. All rights reserved.
//

#import "PFPlace.h"

@implementation PFPlace

+ (NSString*)primaryKey {
   return @"placeID";
}

+ (void)loadFromDictionary:(NSDictionary*)result {
    RLMRealm* realm = [RLMRealm defaultRealm];

    PFPlace* existingPlace = [PFPlace objectForPrimaryKey: result[@"place_id"]];
    if (existingPlace.wasEdited == YES) {
        return;
    }
    [realm beginWriteTransaction];

    PFPlace* place = [[PFPlace alloc] init];
    place.placeID = result[@"place_id"];
    place.name = result[@"name"];
    place.latitude = result[@"geometry"][@"location"][@"lat"];
    place.longitude = result[@"geometry"][@"location"][@"lng"];

    for (NSString* type in result[@"types"]) {
        [place.types addObject:type];
    }

    NSArray<NSDictionary*>* photos = result[@"photos"];
    if ([photos firstObject] != nil) {
        place.photoReference = [photos firstObject][@"photo_reference"];
    }

    [realm addOrUpdateObject:place];
    [realm commitWriteTransaction];
}

+ (NSArray<NSString*>*)filters {
    NSMutableArray* distinctTypes  = [[NSMutableArray alloc] init];
    RLMResults* places = [PFPlace allObjects];
    for (PFPlace* place in places) {
        for (NSString* type in place.types) {
            if ([distinctTypes containsObject:type] == NO) {
                [distinctTypes addObject:type];
            }
        }
    }

    // There are plenty of types, for display purpose selecting 3 shortest
    NSArray<NSString*>* sortedTypes = [distinctTypes sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 length] > [obj2 length];
    }];

    if ([sortedTypes count] > 0) {
        return [sortedTypes subarrayWithRange:NSMakeRange(0, MIN(4, [sortedTypes count] - 1))];
    } else {
        return [NSArray array];
    }
}

- (void)deleteFromRealm {
    [self.realm transactionWithBlock:^{
        [self.realm deleteObject:self];
    }];
}

- (void)detailsFromDictionary:(NSDictionary*)result {
    [self.realm beginWriteTransaction];

    self.address = result[@"adr_address"];
    self.phoneNumber = result[@"formatted_phone_number"];
    self.rating = [NSString stringWithFormat:@"%@", result[@"rating"]];

    [self.realm commitWriteTransaction];
}

- (NSString*)typesString {
    NSMutableArray<NSString*>* types = [NSMutableArray array];
    for (NSString* type in self.types) {
        [types addObject:type];
    }
    return [types componentsJoinedByString:@", "];
}

- (NSString*)locationString {
    return [NSString stringWithFormat:@"%.7f,%.7f", self.latitude.doubleValue, self.longitude.doubleValue];
}

@end

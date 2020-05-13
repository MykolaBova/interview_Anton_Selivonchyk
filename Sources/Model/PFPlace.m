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
    place.latitude = @([result[@"geometry.location.lat"] doubleValue]);
    place.longitude = @([result[@"geometry.location.lng"] doubleValue]);

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

+ (NSArray<NSString*>*)distinctTypes {
    NSMutableArray* distinctTypes  = [[NSMutableArray alloc] init];
    RLMResults* places = [PFPlace allObjects];
    for (PFPlace* place in places) {
        for (NSString* type in place.types) {
            if ([distinctTypes containsObject:type] == NO) {
                [distinctTypes addObject:type];
            }
        }
    }

    return distinctTypes;
}

@end

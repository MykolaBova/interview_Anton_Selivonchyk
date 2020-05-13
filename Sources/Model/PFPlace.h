//
//  PFPlace.h
//  PlaceFinder
//
//  Created by Anton on 5/12/20.
//  Copyright © 2020 Anton. All rights reserved.
//

#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface PFPlace : RLMObject

@property NSString* placeID;
@property NSString* photoReference;
@property NSNumber<RLMDouble>* latitude;
@property NSNumber<RLMDouble>* longitude;
@property NSString* name;
@property BOOL wasEdited;

+ (void)loadFromDictionary:(NSDictionary*)result;

@end
RLM_ARRAY_TYPE(PFPlace)
NS_ASSUME_NONNULL_END

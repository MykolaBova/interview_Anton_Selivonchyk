//
//  PFNetworking.h
//  PlaceFinder
//
//  Created by Anton on 5/13/20.
//  Copyright © 2020 Anton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PFNetworking : NSObject

+ (void)requestCityCoordinates:(NSString*)city completion:(void (^)(CLLocationCoordinate2D coordinate, NSString* _Nullable errorString))completion;
+ (void)requestPlacesFor:(CLLocationCoordinate2D)coordinate completion:(void (^)(NSArray<NSDictionary*>* _Nullable results, NSString* _Nullable errorString))completion;

@end

NS_ASSUME_NONNULL_END

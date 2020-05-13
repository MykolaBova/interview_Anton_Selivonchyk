//
//  AppDelegate.m
//  PlaceFinder
//
//  Created by Anton on 5/11/20.
//  Copyright © 2020 Anton. All rights reserved.
//

#import "AppDelegate.h"
#import <Realm/Realm.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configureRealm];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

#pragma mark - Private interface

- (void)configureRealm {
    RLMRealmConfiguration* config = [RLMRealmConfiguration defaultConfiguration];
//    config.schemaVersion = 1;
    config.shouldCompactOnLaunch = ^BOOL(NSUInteger totalBytes, NSUInteger usedBytes) {
        NSUInteger oneHundredMB = 100 * 1024 * 1024;
        return (totalBytes > oneHundredMB) && ((double)usedBytes / totalBytes) < 0.5;
    };
//    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
//    };

    NSError* error = nil;
    RLMRealm* realm = [RLMRealm realmWithConfiguration:config error:&error];
    if (error != nil) {
        NSLog(@">> Error: %@", [error localizedDescription]);
    }
    NSLog(@" >> realm: %@", realm.description);
}

@end

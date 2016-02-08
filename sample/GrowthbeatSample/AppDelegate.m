//
//  AppDelegate.m
//  GrowthbeatSample
//
//  Created by Kataoka Naoyuki on 2014/08/10.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[Growthbeat sharedInstance] initializeWithApplicationId:@"PIaD6TaVt7wvKwao" credentialId:@"FD2w93wXcWlb68ILOObsKz5P3af9oVMo"];
    [[GrowthbeatCore sharedInstance] addIntentHandler:[[GBCustomIntentHandler alloc] initWithBlock:^BOOL(GBCustomIntent *customIntent) {
        NSDictionary *extra = customIntent.extra;
        NSLog(@"extra: %@", extra);
        return YES;
    }]];
    [[GrowthLink sharedInstance] initializeWithApplicationId:@"PIaD6TaVt7wvKwao" credentialId:@"FD2w93wXcWlb68ILOObsKz5P3af9oVMo"];

    [[GrowthPush sharedInstance] requestDeviceTokenWithEnvironment:kGrowthPushEnvironment];
    [[Growthbeat sharedInstance] getClient:^(GBClient *client) {
        NSLog(@"clientId is %@",client.id);
    }];
    return YES;
}

- (BOOL) application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler{
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *webpageURL = userActivity.webpageURL;
        [[GrowthLink sharedInstance] handleUniversalLinks:webpageURL];
    }
    return true;
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
    [[Growthbeat sharedInstance] start];
}

- (void) applicationWillResignActive:(UIApplication *)application {
    [[Growthbeat sharedInstance] stop];
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[GrowthLink sharedInstance] handleOpenUrl:url];
    return YES;
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[GrowthPush sharedInstance] setDeviceToken:deviceToken];
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotification : %@", error);
}

@end

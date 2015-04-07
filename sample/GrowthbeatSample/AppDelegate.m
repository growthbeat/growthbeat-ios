//
//  AppDelegate.m
//  GrowthbeatSample
//
//  Created by Kataoka Naoyuki on 2014/08/10.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[Growthbeat sharedInstance] initializeWithApplicationId:@"P5C3vzoLOEijnlVj" credentialId:@"btFlFAitBJ1CBdL3IR3ROnhLYbeqmLlY"];
    [[Growthbeat sharedInstance] initializeGrowthAnalytics];
    [[Growthbeat sharedInstance] initializeGrowthMessage];
    
    return YES;
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[Growthbeat sharedInstance] start];
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    [[Growthbeat sharedInstance] stop];
}

@end

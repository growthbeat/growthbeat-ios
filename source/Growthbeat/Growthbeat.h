//
//  Growthbeat.h
//  Growthbeat
//
//  Created by Kataoka Naoyuki on 2014/08/10.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GrowthbeatCore.h"
#import "GrowthAnalytics.h"
#import "GrowthMessage.h"
#import "GrowthPush.h"

@interface Growthbeat : NSObject

+ (instancetype)sharedInstance;

- (void)initializeWithApplicationId:(NSString *)initialApplicationId credentialId:(NSString *)initialCredentialId;

- (void)start;
- (void)stop;
- (void)setLoggerSilent:(BOOL)silent;

@end

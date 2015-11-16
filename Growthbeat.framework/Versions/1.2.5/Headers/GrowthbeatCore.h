//
//  GrowthbeatCore.h
//  GrowthbeatCore
//
//  Created by Kataoka Naoyuki on 2014/06/13.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBLogger.h"
#import "GBHttpClient.h"
#import "GBPreference.h"
#import "GBUtils.h"
#import "GBClient.h"
#import "GBAppDelegateWrapper.h"
#import "GBIntent.h"
#import "GBIntentHandler.h"
#import "GBCustomIntent.h"


@interface GrowthbeatCore : NSObject {

    NSMutableArray *intentHandlers;
}

@property (nonatomic, strong) NSArray *intentHandlers;

+ (GrowthbeatCore *)sharedInstance;

- (void)initializeWithApplicationId:(NSString *)applicationId credentialId:(NSString *)credentialId;

- (GBLogger *)logger;
- (GBHttpClient *)httpClient;
- (GBPreference *)preference;

- (GBClient *)client;
- (GBClient *)waitClient;

- (BOOL)handleIntent:(GBIntent *)intent;
- (void)addIntentHandler:(NSObject *)intentHandler;
- (void)addCustomIntentHandlerWithBlock:(BOOL(^)(GBCustomIntent *customIntent))block;


@end

//
//  Growthbeat.m
//  Growthbeat
//
//  Created by Kataoka Naoyuki on 2014/08/10.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import "Growthbeat.h"

static Growthbeat *sharedInstance = nil;

@interface Growthbeat () {

    NSString *applicationId;
    NSString *credentialId;

}

@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, strong) NSString *credentialId;

@end

@implementation Growthbeat

@synthesize applicationId;
@synthesize credentialId;

+ (instancetype) sharedInstance {
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
}

- (instancetype) init {
    self = [super init];
    if (self) {
        self.applicationId = nil;
        self.credentialId = nil;
    }
    return self;
}

- (void) initializeWithApplicationId:(NSString *)initialApplicationId credentialId:(NSString *)initialCredentialId {
    self.applicationId = initialApplicationId;
    self.credentialId = initialCredentialId;
    [[GrowthbeatCore sharedInstance] initializeWithApplicationId:applicationId credentialId:credentialId];
    [[GrowthAnalytics sharedInstance] initializeWithApplicationId:applicationId credentialId:credentialId];
    [[GrowthMessage sharedInstance] initializeWithApplicationId:applicationId credentialId:credentialId];
    [[GrowthPush sharedInstance] initializeWithApplicationId:applicationId credentialId:credentialId environment:kGrowthPushEnvironment];
}

- (void) start {
    [[GrowthAnalytics sharedInstance] open];
}

- (void) stop {
    [[GrowthAnalytics sharedInstance] close];
}

- (void) setLoggerSilent:(BOOL)silent {
    [[[GrowthbeatCore sharedInstance] logger] setSilent:silent];
    [[[GrowthAnalytics sharedInstance] logger] setSilent:silent];
    [[[GrowthMessage sharedInstance] logger] setSilent:silent];
    [[[GrowthPush sharedInstance] logger] setSilent:silent];
}

@end

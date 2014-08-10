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
    [GrowthbeatCore initializeWithApplicationId:applicationId credentialId:credentialId];
}

- (void) initializeGrowthPushWithEnvironment:(GPEnvironment)environment {
    [GrowthPush initializeWithApplicationId:applicationId credentialId:credentialId environment:environment];
}

@end

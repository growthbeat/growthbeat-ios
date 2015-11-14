//
//  GLSynchronization.h
//  GrowthLink
//
//  Created by Naoyuki Kataoka on 2015/06/05.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GBDomain.h>

@interface GLSynchronization : GBDomain <NSCoding> {

    BOOL cookieTracking;
    BOOL deviceFingerprint;
    NSString *clickId;

}

@property (nonatomic, assign) BOOL cookieTracking;
@property (nonatomic, assign) BOOL deviceFingerprint;
@property (nonatomic, strong) NSString *clickId;

+ (instancetype)synchronizeWithApplicationId:(NSString *)applicationId version:(NSString *)version fingerprintParameters:(NSString *)fingerprintParameters credentialId:(NSString *)credentialId;
+ (void)save:(GLSynchronization *)synchronization;
+ (GLSynchronization *)load;

@end

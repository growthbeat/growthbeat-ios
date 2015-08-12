//
//  GLSynchronization.h
//  GrowthLink
//
//  Created by Naoyuki Kataoka on 2015/06/05.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GBDomain.h>

@interface GLSynchronization : GBDomain <NSCoding> {
    
    NSString *scheme;
    BOOL browser;
    NSString *clickId;
    
}

@property (nonatomic, strong) NSString *scheme;
@property (nonatomic, assign) BOOL browser;
@property (nonatomic, strong) NSString *clickId;

+ (instancetype) synchronizeWithApplicationId:(NSString *)applicationId version:(NSString *)version credentialId:(NSString *)credentialId userAgent:(NSString *)userAgent clientWidthHeight:(NSString *)clientWidthHeight fingerprintParameters:(NSString *)fingerprintParameters;
+ (void) save:(GLSynchronization *)synchronization;
+ (GLSynchronization *) load;

@end

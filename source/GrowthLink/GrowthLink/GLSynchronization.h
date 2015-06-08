//
//  GLSynchronization.h
//  GrowthLink
//
//  Created by Naoyuki Kataoka on 2015/06/05.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"

@interface GLSynchronization : GBDomain <NSCoding> {
    
    NSInteger browser;
    NSString *token;
    
}

@property (nonatomic, assign) NSInteger browser;
@property (nonatomic, strong) NSString *token;

+ (instancetype) getWithApplicationId:(NSString *)applicationId os:(NSInteger)os version:(NSString *)version credentialId:(NSString *)credentialId;
+ (void) save:(GLSynchronization *)synchronization;
+ (GLSynchronization *) load;

@end

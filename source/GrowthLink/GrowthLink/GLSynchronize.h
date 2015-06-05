//
//  GLSynchronize.h
//  GrowthLink
//
//  Created by Naoyuki Kataoka on 2015/06/05.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"

@interface GLSynchronize : GBDomain {
    
    NSDictionary *configuration;
    NSDictionary *click;
    
}

@property (nonatomic, strong) NSDictionary *configuration;
@property (nonatomic, strong) NSDictionary *click;

+ (instancetype) getWithApplicationId:(NSString *)applicationId os:(NSInteger)os version:(NSString *)version credentialId:(NSString *)credentialId;
+ (void) save:(GLSynchronize *)synchronize;
+ (GLSynchronize *) load;

@end

//
//  GLIntent.h
//  GrowthLink
//
//  Created by Naoyuki Kataoka on 2015/06/05.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"
#import "GBIntent.h"

@interface GLIntent : GBDomain {
    
    NSDictionary *link;
    NSDictionary *pattern;
    GBIntent *intent;
    
}

@property (nonatomic, strong) NSDictionary *link;
@property (nonatomic, strong) NSDictionary *pattern;
@property (nonatomic, strong) GBIntent *intent;

+ (instancetype) createWithClientId:(NSString *)clientId token:(NSString *)token install:(NSInteger)install credentialId:(NSString *)credentialId;

@end

//
//  GAClientTag.h
//  GrowthAnalytics
//
//  Created by Kataoka Naoyuki on 2014/11/06.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"

@interface GAClientTag : GBDomain <NSCoding> {
    
    NSString *clientId;
    NSString *tagId;
    NSString *value;
    NSDate *created;
    
}

@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *tagId;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSDate *created;

+ (GAClientTag *)createWithClientId:(NSString *)clientId tagId:(NSString *)tagId value:(NSString *)value credentialId:(NSString *)credentialId;
+ (void) save:(GAClientTag *)clientTag;
+ (GAClientTag *) load:(NSString *)tagId;

@end

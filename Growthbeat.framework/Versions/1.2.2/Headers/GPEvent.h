//
//  GPEvent.h
//  GrowthPush
//
//  Created by uchidas on 2015/06/22.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"

@interface GPEvent : GBDomain<NSCoding> {

    NSInteger goalId;
    long long clientId;
    long long timestamp;
    NSString *value;

}

@property (nonatomic, assign) NSInteger goalId;
@property (nonatomic, assign) long long clientId;
@property (nonatomic, assign) long long timestamp;
@property (nonatomic, strong) NSString *value;

+ (GPEvent *)createWithGrowthbeatClient:(NSString *)clientId credentialId:(NSString *)credentialId name:(NSString *)name value:(NSString *)value;

@end

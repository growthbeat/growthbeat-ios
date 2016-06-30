//
//  GPEvent.h
//  GrowthPush
//
//  Created by uchidas on 2015/06/22.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"
#import "GPEventType.h"

@interface GPEvent : GBDomain<NSCoding> {

    NSInteger goalId;
    NSString *clientId;
    long long timestamp;
    NSString *value;

}

@property (nonatomic, assign) NSInteger goalId;
@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, assign) long long timestamp;
@property (nonatomic, strong) NSString *value;

+ (GPEvent *)createWithGrowthbeatClient:(NSString *)clientId applicationId:(NSString *)applicationId credentialId:(NSString *)credentialId type:(GPEventType)eventType name:(NSString *)name value:(NSString *)value;

@end

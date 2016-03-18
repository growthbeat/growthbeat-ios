//
//  GBGPClient.h
//  GrowthbeatCore
//
//  Created by uchidas on 2015/05/22.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"

@interface GBGPClient : GBDomain<NSCoding> {

    long long id;
    NSInteger applicationId;
    NSString *code;
    NSString *growthbeatApplicationId;
    NSString *growthbeatClientId;
    NSString *token;
    NSString *os;
    NSString *environment;
    NSDate *created;

}

@property (nonatomic, assign) long long id;
@property (nonatomic, assign) NSInteger applicationId;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *growthbeatApplicationId;
@property (nonatomic, strong) NSString *growthbeatClientId;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *os;
@property (nonatomic, strong) NSString *environment;
@property (nonatomic, strong) NSDate *created;

+ (GBGPClient *)load;
+ (void)removePreference;
+ (GBGPClient *)findWithGPClientId:(long long)clientId code:(NSString *)code;

@end
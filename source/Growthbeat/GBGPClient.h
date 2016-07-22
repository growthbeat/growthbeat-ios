//
//  GBGPClient.h
//  Growthbeat
//  client migrate GrowthPush SDK to Growthbeat SDK
//
//  Created by 尾川 茂 on 2016/07/22.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
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
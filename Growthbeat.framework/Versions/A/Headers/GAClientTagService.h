//
//  GAClientTagService.h
//  GrowthAnalytics
//
//  Created by Kataoka Naoyuki on 2014/11/06.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import "GAService.h"
#import "GAClientTag.h"

@interface GAClientTagService : GAService

+ (GAClientTagService *)sharedInstance;
- (void)createWithClientId:(NSString *)clientId tagId:(NSString *)tagId value:(NSString *)value success:(void(^) (GAClientTag * clientTag)) success fail:(void(^) (NSInteger status, NSError * error))fail;

@end

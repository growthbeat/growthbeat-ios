//
//  GAClientEventService.h
//  GrowthAnalytics
//
//  Created by Kataoka Naoyuki on 2014/11/06.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import "GAService.h"
#import "GAClientEvent.h"

@interface GAClientEventService : GAService

+ (GAClientEventService *)sharedInstance;
- (void)createWithClientId:(NSString *)clientId eventId:(NSString *)eventId properties:(NSDictionary *)properties success:(void(^) (GAClientEvent * clientEvent)) success fail:(void(^) (NSInteger status, NSError * error))fail;

@end

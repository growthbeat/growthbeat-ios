//
//  GAClientEvent.h
//  GrowthAnalytics
//
//  Created by Kataoka Naoyuki on 2014/11/06.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import "GADomain.h"

@interface GAClientEvent : GADomain {
    
    NSString *id;
    NSString *clientId;
    NSString *eventId;
    NSDictionary *properties;
    NSDate *created;
    
}

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, strong) NSDictionary *properties;
@property (nonatomic, strong) NSDate *created;

@end

//
//  GAEventHandler.m
//  GrowthAnalytics
//
//  Created by Naoyuki Kataoka on 2015/03/13.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GAEventHandler.h"

@implementation GAEventHandler

@synthesize callback;

- (instancetype) initWithCallback:(void (^)(NSString *eventId, NSDictionary *properties))newCallback {
    self = [super init];
    if (self) {
        self.callback = newCallback;
    }
    return self;
}

@end

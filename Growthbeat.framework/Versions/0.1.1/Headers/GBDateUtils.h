//
//  GBDateUtils.h
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2014/06/13.
//  Copyright (c) 2014 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBDateUtils : NSObject

+ (NSDate *)dateWithDateTimeString:(NSString *)dateTimeString;
+ (NSDate *)dateWithString:(NSString *)string format:(NSString *)format;

@end

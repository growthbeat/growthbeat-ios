//
//  GBDeviceUtils.h
//  GrowthbeatCore
//
//  Created by Kataoka Naoyuki on 2013/07/14.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBDeviceUtils : NSObject

+ (NSString *)model;
+ (NSString *)os;
+ (NSString *)language;
+ (NSString *)timeZone;
+ (NSInteger)timeZoneOffset;
+ (NSString *)locale;
+ (NSString *)country;
+ (NSString *)version;
+ (NSString *)build;
+ (BOOL)connectedToWiFi;
+ (float)getCurrentDeviceVersion;
+ (unsigned int)getAvailableMemory;
+ (uint64_t)getCPUUsage;
+ (NSString *)getPlatformString;
+ (NSString *)getAdvertisingId;
+ (BOOL)getTrackingEnabled;

@end

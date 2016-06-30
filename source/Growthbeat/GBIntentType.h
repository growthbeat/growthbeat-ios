//
//  GBIntentType.h
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2015/03/17.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, GBIntentType) {
    GBIntentTypeUnknown = 0,
    GBIntentTypeCustom,
    GBIntentTypeNoop,
    GBIntentTypeUrl
};

NSString *NSStringFromGBIntentType(GBIntentType intentType);
GBIntentType GBIntentTypeFromNSString(NSString *intentTypeString);

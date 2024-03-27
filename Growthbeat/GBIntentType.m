//
//  GBIntentType.m
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2015/03/17.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GBIntentType.h>

NSString *NSStringFromContnetType(GBIntentType intentType) {

    switch (intentType) {
        case GBIntentTypeUnknown:
            return nil;
        case GBIntentTypeCustom:
            return @"custom";
        case GBIntentTypeNoop:
            return @"noop";
        case GBIntentTypeUrl:
            return @"url";
    }

}

GBIntentType GBIntentTypeFromNSString(NSString *intentTypeString) {

    if ([intentTypeString isEqualToString:@"custom"]) {
        return GBIntentTypeCustom;
    }
    if ([intentTypeString isEqualToString:@"noop"]) {
        return GBIntentTypeNoop;
    }
    if ([intentTypeString isEqualToString:@"url"]) {
        return GBIntentTypeUrl;
    }
    return GBIntentTypeUnknown;

}
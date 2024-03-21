//
//  GPEventType.m
//  Growthbeat
//
//  Created by TABATAKATSUTOSHI on 2016/06/21.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GPEventType.h>

NSString *NSStringFromGPEventType(GPEventType eventType) {
    switch (eventType) {
        case GPEventTypeCustom:
            return @"custom";
        case GPEventTypeMessage:
            return @"message";
        case GPEventTypeUnknown:
            return nil;
    }
}

GPEventType GPEventTypeFromNSString(NSString *eventTypeString) {
    if ([eventTypeString isEqualToString:@"custom"]) {
        return GPEventTypeCustom;
    }
    if ([eventTypeString isEqualToString:@"message"]) {
        return GPEventTypeMessage;
    }
    return GPEventTypeUnknown;
}

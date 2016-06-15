//
//  GPMessageType.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPMessageType.h"

NSString *NSStringFromGPMessageType(GPMessageType messageType) {
    
    switch (messageType) {
        case GPMessageTypePlain:
            return @"plain";
        case GPMessageTypeImage:
            return @"image";
        case GPMessageTypeBanner:
            return @"banner";
        case GPMessageTypeSwipe:
            return @"swipe";
        case GPMessageTypeUnknown:
            return nil;
    }
    
}

GPMessageType GPMessageTypeFromNSString(NSString *messageTypeString) {
    
    if ([messageTypeString isEqualToString:@"plain"]) {
        return GPMessageTypePlain;
    }
    if ([messageTypeString isEqualToString:@"image"]) {
        return GPMessageTypeImage;
    }
    if ([messageTypeString isEqualToString:@"banner"]) {
        return GPMessageTypeBanner;
    }
    if ([messageTypeString isEqualToString:@"swipe"]) {
        return GPMessageTypeSwipe;
    }
    return GPMessageTypeUnknown;
    
}
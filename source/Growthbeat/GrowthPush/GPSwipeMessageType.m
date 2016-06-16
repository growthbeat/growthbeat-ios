//
//  GPSwipeMessageType.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPSwipeMessageType.h"

NSString *NSStringFromGPSwipeMessageType(GPSwipeMessageType swipeMessageType) {
    
    switch (swipeMessageType) {
        case GPSwipeMessageTypeUnknown:
            return nil;
        case GPSwipeMessageTypeImageOnly:
            return @"imageOnly";
        case GPSwipeMessageTypeOneButton:
            return @"oneButton";
    }
    
}

GPSwipeMessageType GPSwipeMessageTypeFromNSString(NSString *swipeMessageTypeString) {
    
    if ([swipeMessageTypeString isEqualToString:@"imageOnly"]) {
        return GPSwipeMessageTypeImageOnly;
    }
    if ([swipeMessageTypeString isEqualToString:@"oneButton"]) {
        return GPSwipeMessageTypeOneButton;
    }
    return GPSwipeMessageTypeUnknown;
    
}

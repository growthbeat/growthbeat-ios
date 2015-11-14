//
//  GMSwipeMessageType.m
//  GrowthMessage
//
//  Created by 田村 俊太郎 on 2015/07/14.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMSwipeMessageType.h"

NSString *NSStringFromGMSwipeMessageType(GMSwipeMessageType swipeMessageType) {

    switch (swipeMessageType) {
        case GMSwipeMessageTypeUnknown:
            return nil;
        case GMSwipeMessageTypeImageOnly:
            return @"imageOnly";
        case GMSwipeMessageTypeOneButton:
            return @"oneButton";
        case GMSwipeMessageTypeButtons:
            return @"buttons";
    }

}

GMSwipeMessageType GMSwipeMessageTypeFromNSString(NSString *swipeMessageTypeString) {

    if ([swipeMessageTypeString isEqualToString:@"imageOnly"]) {
        return GMSwipeMessageTypeImageOnly;
    }
    if ([swipeMessageTypeString isEqualToString:@"oneButton"]) {
        return GMSwipeMessageTypeOneButton;
    }
    if ([swipeMessageTypeString isEqualToString:@"buttons"]) {
        return GMSwipeMessageTypeButtons;
    }
    return GMSwipeMessageTypeUnknown;

}

//
//  GMSwipeMessageType.h
//  GrowthMessage
//
//  Created by 田村 俊太郎 on 2015/07/12.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, GMSwipeMessageType) {
    GMSwipeMessageTypeUnknown = 0,
    GMSwipeMessageTypeImageOnly,
    GMSwipeMessageTypeOneButton,
    GMSwipeMessageTypeButtons
};

NSString *NSStringFromGMSwipeMessageType(GMSwipeMessageType swipeMessageType);
GMSwipeMessageType GMSwipeMessageTypeFromNSString(NSString *swipeMessageTypeString);

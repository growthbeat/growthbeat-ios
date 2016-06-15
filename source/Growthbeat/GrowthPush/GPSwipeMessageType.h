//
//  GPSwipeMessageType.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, GPSwipeMessageType) {
    GPSwipeMessageTypeUnknown = 0,
    GPSwipeMessageTypeImageOnly,
    GPSwipeMessageTypeOneButton,
    GPSwipeMessageTypeButtons
};

NSString *NSStringFromGPSwipeMessageType(GPSwipeMessageType swipeMessageType);
GPSwipeMessageType GPSwipeMessageTypeFromNSString(NSString *swipeMessageTypeString);

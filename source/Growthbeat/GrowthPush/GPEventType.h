//
//  GPEventType.h
//  Growthbeat
//
//  Created by TABATAKATSUTOSHI on 2016/06/21.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, GPEventType) {
    GPEventTypeUnknown = 0,
    GPEventTypeDefault,
    GPEventTypeCustom,
    GPEventTypeMessage
};

NSString *NSStringFromGPEventType(GPEventType eventType);
GPEventType GPEventTypeFromNSString(NSString *eventTypeString);

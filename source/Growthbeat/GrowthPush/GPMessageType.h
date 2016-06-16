//
//  GPMessageType.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, GPMessageType) {
    GPMessageTypeUnknown = 0,
    GPMessageTypePlain,
    GPMessageTypeImage,
    GPMessageTypeSwipe
};

NSString *NSStringFromGPMessageType(GPMessageType messageType);
GPMessageType GPMessageTypeFromNSString(NSString *messageTypeString);

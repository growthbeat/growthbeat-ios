//
//  GMMessageType.h
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/03/16.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, GMMessageType) {
    GMMessageTypeUnknown = 0,
    GMMessageTypePlain,
    GMMessageTypeImage,
    GMMessageTypeBanner,
    GMMessageTypeSwipe
};

NSString *NSStringFromGMMessageType(GMMessageType messageType);
GMMessageType GMMessageTypeFromNSString(NSString *messageTypeString);

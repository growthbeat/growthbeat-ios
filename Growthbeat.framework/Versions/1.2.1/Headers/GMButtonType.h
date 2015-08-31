//
//  GMButtonType.h
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/03/17.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, GMButtonType) {
    GMButtonTypeUnknown = 0,
    GMButtonTypePlain,
    GMButtonTypeImage,
    GMButtonTypeClose,
    GMButtonTypeScreen
};

NSString *NSStringFromGMButtonType(GMButtonType buttonType);
GMButtonType GMButtonTypeFromNSString(NSString *buttonTypeString);

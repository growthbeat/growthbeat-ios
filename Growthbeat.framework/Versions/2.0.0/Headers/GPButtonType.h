//
//  GPButtonType.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, GPButtonType) {
    GPButtonTypeUnknown = 0,
    GPButtonTypePlain,
    GPButtonTypeImage,
    GPButtonTypeClose,
    GPButtonTypeScreen
};

NSString *NSStringFromGPButtonType(GPButtonType buttonType);
GPButtonType GPButtonTypeFromNSString(NSString *buttonTypeString);

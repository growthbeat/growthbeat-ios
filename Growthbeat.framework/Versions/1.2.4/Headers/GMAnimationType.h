//
//  GMAnimationType.h
//  GrowthMessage
//
//  Created by 田村 俊太郎 on 2015/07/21.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, GMAnimationType) {
    GMAnimationTypeUnknown = 0,
    GMAnimationTypeNone,
    GMAnimationTypeDefaults
};

NSString *NSStringFromGMAnimationType(GMAnimationType animationType);
GMAnimationType GMAnimationTypeFromNSString(NSString *animationTypeString);

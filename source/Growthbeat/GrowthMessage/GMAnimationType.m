//
//  GMAnimationType.m
//  GrowthMessage
//
//  Created by 田村 俊太郎 on 2015/07/21.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMAnimationType.h"

NSString *NSStringFromGMAnimationType(GMAnimationType animationType) {

    switch (animationType) {
        case GMAnimationTypeNone:
            return @"none";
        case GMAnimationTypeDefaults:
            return @"defaults";
        case GMAnimationTypeUnknown:
            return nil;
    }

}

GMAnimationType GMAnimationTypeFromNSString(NSString *animationTypeString) {

    if ([animationTypeString isEqualToString:@"none"]) {
        return GMAnimationTypeNone;
    }
    if ([animationTypeString isEqualToString:@"defaults"]) {
        return GMAnimationTypeDefaults;
    }
    return GMAnimationTypeUnknown;

}

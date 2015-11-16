//
//  GMBannerMessageType.m
//  GrowthMessage
//
//  Created by Baekwoo Chung on 2015/06/02.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMBannerMessageType.h"

NSString *NSStringFromGMBannerMessageType(GMBannerMessageType bannerMessageType) {

    switch (bannerMessageType) {
        case GMBannerMessageTypeUnknown:
            return nil;
        case GMBannerMessageTypeOnlyImage:
            return @"onlyImage";
        case GMBannerMessageTypeImageText:
            return @"imageText";
    }

}

GMBannerMessageType GMBannerMessageTypeFromNSString(NSString *bannerMessageTypeString) {

    if ([bannerMessageTypeString isEqualToString:@"onlyImage"]) {
        return GMBannerMessageTypeOnlyImage;
    }
    if ([bannerMessageTypeString isEqualToString:@"imageText"]) {
        return GMBannerMessageTypeImageText;
    }
    return GMBannerMessageTypeUnknown;

}
//
//  GMBannerType.m
//  GrowthMessage
//
//  Created by Baekwoo Chung on 2015/06/02.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMBannerType.h"

NSString *NSStringFromGMBannerType(GMBannerType bannerType) {
    
    switch (bannerType) {
        case GMBannerTypeUnknown:
            return nil;
        case GMBannerTypeOnlyImage:
            return @"onlyImage";
        case GMBannerTypeImageText:
            return @"imageText";
        case GMBannerPositionTop:
            return @"top";
        case GMBannerPositionBottom:
            return @"bottom";
    }
    
}

GMBannerType GMBannerTypeFromNSString(NSString *bannerTypeString) {
    
    if ([bannerTypeString isEqualToString:@"onlyImage"]) {
        return GMBannerTypeOnlyImage;
    }
    if ([bannerTypeString isEqualToString:@"imageText"]) {
        return GMBannerTypeImageText;
    }
    if ([bannerTypeString isEqualToString:@"top"]) {
        return GMBannerPositionTop;
    }
    if ([bannerTypeString isEqualToString:@"bottom"]) {
        return GMBannerPositionBottom;
    }
    return GMBannerTypeUnknown;
    
}
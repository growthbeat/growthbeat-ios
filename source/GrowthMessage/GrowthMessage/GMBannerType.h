//
//  GMBannerType.h
//  GrowthMessage
//
//  Created by Baekwoo Chung on 2015/06/02.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, GMBannerType) {
    GMBannerTypeUnknown = 0,
    GMBannerTypeOnlyImage,
    GMBannerTypeImageText
};

NSString *NSStringFromGMBannerType(GMBannerType bannerType);
GMBannerType GMBannerTypeFromNSString(NSString *bannerTypeString);

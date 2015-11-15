//
//  GMBannerMessageType.h
//  GrowthMessage
//
//  Created by Baekwoo Chung on 2015/06/02.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, GMBannerMessageType) {
    GMBannerMessageTypeUnknown = 0,
    GMBannerMessageTypeOnlyImage,
    GMBannerMessageTypeImageText
};

NSString *NSStringFromGMBannerMessageType(GMBannerMessageType bannerMessageType);
GMBannerMessageType GMBannerMessageTypeFromNSString(NSString *bannerMessageTypeString);

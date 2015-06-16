//
//  GMBannerPosition.h
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/06/16.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, GMBannerPosition) {
    GMBannerPositionUnknown = 0,
    GMBannerPositionTop,
    GMBannerPositionBottom
};

NSString *NSStringFromGMBannerPosition(GMBannerPosition bannerPosition);
GMBannerPosition GMBannerPositionFromNSString(NSString *bannerPositionString);

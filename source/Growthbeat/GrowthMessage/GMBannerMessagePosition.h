//
//  GMBannerMessagePosition.h
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/06/16.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, GMBannerMessagePosition) {
    GMBannerMessagePositionUnknown = 0,
    GMBannerMessagePositionTop,
    GMBannerMessagePositionBottom
};

NSString *NSStringFromGMBannerMessagePosition(GMBannerMessagePosition bannerMessagePosition);
GMBannerMessagePosition GMBannerMessagePositionFromNSString(NSString *bannerMessagePositionString);

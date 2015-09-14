//
//  GMBannerMessagePosition.m
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/06/16.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMBannerMessagePosition.h"

NSString *NSStringFromGMBannerMessagePosition(GMBannerMessagePosition bannerMessagePosition) {
    
    switch (bannerMessagePosition) {
        case GMBannerMessagePositionUnknown:
            return nil;
        case GMBannerMessagePositionTop:
            return @"top";
        case GMBannerMessagePositionBottom:
            return @"bottom";
    }
    
}

GMBannerMessagePosition GMBannerMessagePositionFromNSString(NSString *bannerMessagePositionString) {
    
    if ([bannerMessagePositionString isEqualToString:@"top"]) {
        return GMBannerMessagePositionTop;
    }
    if ([bannerMessagePositionString isEqualToString:@"bottom"]) {
        return GMBannerMessagePositionBottom;
    }
    return GMBannerMessagePositionUnknown;
    
}
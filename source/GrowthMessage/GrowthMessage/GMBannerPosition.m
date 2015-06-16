//
//  GMBannerPosition.m
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/06/16.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMBannerPosition.h"

NSString *NSStringFromGMBannerPosition(GMBannerPosition bannerPosition) {
    
    switch (bannerPosition) {
        case GMBannerPositionUnknown:
            return nil;
        case GMBannerPositionTop:
            return @"top";
        case GMBannerPositionBottom:
            return @"bottom";
    }
    
}

GMBannerPosition GMBannerPositionFromNSString(NSString *bannerPositionString) {
    
    if ([bannerPositionString isEqualToString:@"top"]) {
        return GMBannerPositionTop;
    }
    if ([bannerPositionString isEqualToString:@"bottom"]) {
        return GMBannerPositionBottom;
    }
    return GMBannerPositionUnknown;
    
}
//
//  GMPictureExtension.m
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/04/20.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMPictureExtension.h"

NSString *NSStringFromGMPictureExtension(GMPictureExtension messageExtension) {

    switch (messageExtension) {
        case GMPictureExtensionPNG:
            return @"png";
        case GMPictureExtensionJPG:
            return @"jpg";
        case GMPictureExtensionUnknown:
            return nil;
    }

}

GMPictureExtension GMPictureExtensionFromNSString(NSString *messageExtensionString) {

    if ([messageExtensionString isEqualToString:@"png"]) {
        return GMPictureExtensionPNG;
    }
    if ([messageExtensionString isEqualToString:@"jpg"]) {
        return GMPictureExtensionJPG;
    }
    return GMPictureExtensionUnknown;

}
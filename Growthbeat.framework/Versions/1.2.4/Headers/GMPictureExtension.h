//
//  GMPictureExtension.h
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/04/20.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, GMPictureExtension) {
    GMPictureExtensionUnknown = 0,
    GMPictureExtensionPNG,
    GMPictureExtensionJPG
};

NSString *NSStringFromGMPictureExtension(GMPictureExtension messageExtension);
GMPictureExtension GMPictureExtensionFromNSString(NSString *messageExtensionString);

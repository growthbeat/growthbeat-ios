//
//  GPPictureExtension.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, GPPictureExtension) {
    GPPictureExtensionUnknown = 0,
    GPPictureExtensionPNG,
    GPPictureExtensionJPG
};

NSString *NSStringFromGPPictureExtension(GPPictureExtension messageExtension);
GPPictureExtension GPPictureExtensionFromNSString(NSString *messageExtensionString);

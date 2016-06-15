//
//  GPPictureExtension.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPPictureExtension.h"

NSString *NSStringFromGPPictureExtension(GPPictureExtension messageExtension) {
    
    switch (messageExtension) {
        case GPPictureExtensionPNG:
            return @"png";
        case GPPictureExtensionJPG:
            return @"jpg";
        case GPPictureExtensionUnknown:
            return nil;
    }
    
}

GPPictureExtension GPPictureExtensionFromNSString(NSString *messageExtensionString) {
    
    if ([messageExtensionString isEqualToString:@"png"]) {
        return GPPictureExtensionPNG;
    }
    if ([messageExtensionString isEqualToString:@"jpg"]) {
        return GPPictureExtensionJPG;
    }
    return GPPictureExtensionUnknown;
    
}
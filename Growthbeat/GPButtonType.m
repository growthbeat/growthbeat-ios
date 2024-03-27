//
//  GPButtonType.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GPButtonType.h>

NSString *NSStringFromGPButtonType(GPButtonType buttonType) {
    
    switch (buttonType) {
        case GPButtonTypeUnknown:
            return nil;
        case GPButtonTypePlain:
            return @"plain";
        case GPButtonTypeImage:
            return @"image";
        case GPButtonTypeClose:
            return @"close";
        case GPButtonTypeScreen:
            return @"screen";
    }
    
}

GPButtonType GPButtonTypeFromNSString(NSString *buttonTypeString) {
    
    if ([buttonTypeString isEqualToString:@"plain"]) {
        return GPButtonTypePlain;
    }
    if ([buttonTypeString isEqualToString:@"image"]) {
        return GPButtonTypeImage;
    }
    if ([buttonTypeString isEqualToString:@"close"]) {
        return GPButtonTypeClose;
    }
    if ([buttonTypeString isEqualToString:@"screen"]) {
        return GPButtonTypeScreen;
    }
    return GPButtonTypeUnknown;
    
}
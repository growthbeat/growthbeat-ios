//
//  GPTagType.m
//  Growthbeat
//
//  Created by TABATAKATSUTOSHI on 2016/06/21.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GPTagType.h>

NSString *NSStringFromGPTagType(GPTagType tagType) {
    switch (tagType) {
        case GPTagTypeCustom:
            return @"custom";
        case GPTagTypeMessage:
            return @"message";
        case GPTagTypeUnknown:
            return nil;
    }
}
GPTagType GPTagTypeFromNSString(NSString *tagTypeString) {
    if ([tagTypeString isEqualToString:@"custom"]) {
        return GPTagTypeCustom;
    }
    if ([tagTypeString isEqualToString:@"message"]) {
        return GPTagTypeMessage;
    }
    return GPTagTypeUnknown;
}

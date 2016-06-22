//
//  GPTagType.h
//  Growthbeat
//
//  Created by TABATAKATSUTOSHI on 2016/06/21.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, GPTagType) {
    GPTagTypeUnknown = 0,
    GPTagTypeCustom,
    GPTagTypeMessage
};

NSString *NSStringFromGPTagType(GPTagType tagType);
GPTagType GPTagTypeFromNSString(NSString *tagTypeString);

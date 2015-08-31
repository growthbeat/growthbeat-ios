//
//  GBContentType.h
//  replay
//
//  Created by Kataoka Naoyuki on 2014/02/05.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, GBContentType) {
    GBContentTypeUnknown = 0,
    GBContentTypeFormUrlEncoded,
    GBContentTypeMultipart,
    GBContentTypeJson
};

NSString *NSStringFromGBContentType(GBContentType contentType);
GBContentType GBContentTypeFromNSString(NSString *contentTypeString);

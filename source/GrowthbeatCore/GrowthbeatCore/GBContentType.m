//
//  GBContentType.m
//  replay
//
//  Created by Kataoka Naoyuki on 2014/02/05.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GBContentType.h"

NSString *NSStringFromGBContentType(GBContentType contentType) {

    switch (contentType) {
        case GBContentTypeUnknown:
            return nil;
        case GBContentTypeFormUrlEncoded:
            return @"application/x-www-form-urlencoded";
        case GBContentTypeMultipart:
            return @"multipart/form-data";
        case GBContentTypeJson:
            return @"application/json";
    }

}

GBContentType GBContentTypeFromNSString(NSString *contentTypeString) {

    if ([contentTypeString isEqualToString:@"application/x-www-form-urlencoded"]) {
        return GBContentTypeFormUrlEncoded;
    }
    if ([contentTypeString isEqualToString:@"multipart/form-data"]) {
        return GBContentTypeMultipart;
    }
    if ([contentTypeString isEqualToString:@"application/json"]) {
        return GBContentTypeJson;
    }
    return GBContentTypeUnknown;

}
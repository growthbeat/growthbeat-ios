//
//  GBRequestMethod.m
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2014/06/12.
//  Copyright (c) 2014 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GBRequestMethod.h>

NSString *NSStringFromGBRequestMethod(GBRequestMethod requestMethod) {

    switch (requestMethod) {
        case GBRequestMethodGet:
            return @"GET";
        case GBRequestMethodPost:
            return @"POST";
        case GBRequestMethodPut:
            return @"PUT";
        case GBRequestMethodDelete:
            return @"DELETE";
        default:
            return nil;
    }

}

GBRequestMethod GBRequestMethodFromNSString(NSString *requestMethodString) {

    if ([requestMethodString isEqualToString:@"GET"]) {
        return GBRequestMethodGet;
    }
    if ([requestMethodString isEqualToString:@"POST"]) {
        return GBRequestMethodPost;
    }
    if ([requestMethodString isEqualToString:@"PUT"]) {
        return GBRequestMethodPut;
    }
    if ([requestMethodString isEqualToString:@"DELETE"]) {
        return GBRequestMethodDelete;
    }

    return GBRequestMethodUnknown;

}

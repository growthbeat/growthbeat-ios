//
//  GBRequestMethod.h
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2014/06/12.
//  Copyright (c) 2014 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, GBRequestMethod) {
    GBRequestMethodUnknown = 0,
    GBRequestMethodGet,
    GBRequestMethodPost,
    GBRequestMethodPut,
    GBRequestMethodDelete
};

NSString *NSStringFromGBRequestMethod(GBRequestMethod requestMethod);
GBRequestMethod GBRequestMethodFromNSString(NSString *requestMethodString);

//
//  GBHttpClient.h
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2014/06/12.
//  Copyright (c) 2014 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBHttpRequest.h"
#import "GBHttpResponse.h"

@interface GBHttpClient : NSObject {

    NSURL *baseUrl;
    NSTimeInterval timeout;

}

@property (nonatomic, strong) NSURL *baseUrl;
@property (nonatomic, assign) NSTimeInterval timeout;

- (instancetype)initWithBaseUrl:(NSURL *)initialBaseUrl timeout:(NSTimeInterval)timeout;
- (GBHttpResponse *)httpRequest:(GBHttpRequest *)httpRequest;

@end

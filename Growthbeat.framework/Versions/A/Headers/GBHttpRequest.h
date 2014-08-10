//
//  GBHttpRequest.h
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2014/06/12.
//  Copyright (c) 2014 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBRequestMethod.h"

@interface GBHttpRequest : NSObject {

    GBRequestMethod method;
    NSString *path;
    NSDictionary *query;
    NSDictionary *body;

}

@property (nonatomic, assign) GBRequestMethod method;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSDictionary *query;
@property (nonatomic, strong) NSDictionary *body;

+ (id)instanceWithMethod:(GBRequestMethod)method path:(NSString *)path;
+ (id)instanceWithMethod:(GBRequestMethod)method path:(NSString *)path query:(NSDictionary *)query;
+ (id)instanceWithMethod:(GBRequestMethod)method path:(NSString *)path query:(NSDictionary *)query body:(NSDictionary *)body;

- (NSURLRequest *)urlRequestWithBaseUrl:(NSURL *)baseUrl;

@end

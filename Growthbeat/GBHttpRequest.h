//
//  GBHttpRequest.h
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growthbeat/GBRequestMethod.h>
#import <Growthbeat/GBContentType.h>

@interface GBHttpRequest : NSObject {

    GBRequestMethod requestMethod;
    GBContentType contentType;
    NSString *path;
    NSString *userAgent;
    NSDictionary *query;
    NSDictionary *body;

}

@property (nonatomic) GBRequestMethod requestMethod;
@property (nonatomic) GBContentType contentType;
@property (nonatomic) NSString *path;
@property (nonatomic) NSString *userAgent;
@property (nonatomic) NSDictionary *query;
@property (nonatomic) NSDictionary *body;

+ (id)instanceWithMethod:(GBRequestMethod)requestMethod path:(NSString *)path;
+ (id)instanceWithMethod:(GBRequestMethod)requestMethod path:(NSString *)path query:(NSDictionary *)query;
+ (id)instanceWithMethod:(GBRequestMethod)requestMethod path:(NSString *)path query:(NSDictionary *)query body:(NSDictionary *)body;
+ (id)instanceWithMethod:(GBRequestMethod)requestMethod path:(NSString *)path query:(NSDictionary *)query body:(NSDictionary *)body contentType:(GBContentType)contentType;
+ (id)instanceWithMethod:(GBRequestMethod)requestMethod path:(NSString *)path query:(NSDictionary *)query body:(NSDictionary *)body userAgent:(NSString *)userAgent;

- (NSURLRequest *)urlRequestWithBaseUrl:(NSURL *)baseUrl;

@end

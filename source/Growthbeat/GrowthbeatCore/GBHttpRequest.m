//
//  GBHttpRequest.m
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import "GBHttpRequest.h"
#import "GBUtils.h"

@implementation GBHttpRequest

@synthesize requestMethod;
@synthesize contentType;
@synthesize userAgent;
@synthesize path;
@synthesize query;
@synthesize body;

+ (id) instanceWithMethod:(GBRequestMethod)requestMethod path:(NSString *)path {

    GBHttpRequest *httpRequest = [[self alloc] init];

    httpRequest.requestMethod = requestMethod;
    httpRequest.path = path;

    return httpRequest;

}

+ (id) instanceWithMethod:(GBRequestMethod)requestMethod path:(NSString *)path query:(NSDictionary *)query {

    GBHttpRequest *httpRequest = [self instanceWithMethod:requestMethod path:path];

    httpRequest.query = query;

    return httpRequest;

}

+ (id) instanceWithMethod:(GBRequestMethod)requestMethod path:(NSString *)path query:(NSDictionary *)query body:(NSDictionary *)body {

    GBHttpRequest *httpRequest = [self instanceWithMethod:requestMethod path:path query:query];

    httpRequest.body = body;

    return httpRequest;

}

+ (id) instanceWithMethod:(GBRequestMethod)requestMethod path:(NSString *)path query:(NSDictionary *)query body:(NSDictionary *)body contentType:(GBContentType)contentType {

    GBHttpRequest *httpRequest = [self instanceWithMethod:requestMethod path:path query:query body:body];

    httpRequest.contentType = contentType;

    return httpRequest;

}

+ (id)instanceWithMethod:(GBRequestMethod)requestMethod path:(NSString *)path query:(NSDictionary *)query body:(NSDictionary *)body userAgent:(NSString *)userAgent {

    GBHttpRequest *httpRequest = [self instanceWithMethod:requestMethod path:path query:query body:body];
    
    httpRequest.userAgent = userAgent;
    
    return httpRequest;
}

- (void) dealloc {

    self.path = nil;
    self.query = nil;
    self.body = nil;

}

- (NSURLRequest *) urlRequestWithBaseUrl:(NSURL *)baseUrl {

    if (contentType == GBContentTypeUnknown) {
        contentType = GBContentTypeFormUrlEncoded;
    }

    NSString *requestPath = path ? path : @"";
    NSMutableDictionary *requestQuery = [NSMutableDictionary dictionaryWithDictionary:query];
    NSData *requestBody = nil;
    NSString *contentTypeString = nil;

    if (requestMethod == GBRequestMethodGet) {
        [requestQuery addEntriesFromDictionary:body];
    } else {
        switch (contentType) {
            case GBContentTypeFormUrlEncoded:
                requestBody = [GBHttpUtils formUrlencodedBodyWithDictionary:body];
                break;
            case GBContentTypeJson:
                requestBody = [GBHttpUtils jsonBodyWithDictionary:body];
                break;
            case GBContentTypeMultipart:
                requestBody = [GBHttpUtils multipartBodyWithDictionary:body];
                break;
            default:
                break;
        }
    }

    switch (contentType) {
        case GBContentTypeMultipart:
            contentTypeString = [NSString stringWithFormat:@"%@; boundary=%@; charset=%@", NSStringFromGBContentType(contentType), kMultipartBoundary, CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))];
            break;
        default:
            contentTypeString = [NSString stringWithFormat:@"%@; charset=%@", NSStringFromGBContentType(contentType), CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))];
            break;
    }

    NSString *requestQueryString = [GBHttpUtils queryStringWithDictionary:requestQuery];

    if ([requestQueryString length] > 0) {
        requestPath = [NSString stringWithFormat:@"%@?%@", requestPath, requestQueryString];
    }

    NSURL *url = [NSURL URLWithString:requestPath relativeToURL:baseUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:NSStringFromGBRequestMethod(requestMethod)];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    if (self.userAgent) {
        [urlRequest setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
    }

    if (requestMethod != GBRequestMethodGet) {
        [urlRequest setValue:contentTypeString forHTTPHeaderField:@"Content-Type"];
        [urlRequest setHTTPBody:requestBody];
    }

    return urlRequest;

}

@end

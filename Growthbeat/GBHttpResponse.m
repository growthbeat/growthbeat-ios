//
//  GBHttpResponse.m
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2014/06/12.
//  Copyright (c) 2014 SIROK, Inc. All rights reserved.
//

#import "GBHttpResponse.h"

@implementation GBHttpResponse

@synthesize urlRequest;
@synthesize httpUrlResponse;
@synthesize error;
@synthesize body;

+ (id) instanceWithUrlRequest:(NSURLRequest *)urlRequest httpUrlResponse:(NSHTTPURLResponse *)httpUrlResponse error:(NSError *)error body:(id)body {

    GBHttpResponse *httpResponse = [[self alloc] init];

    httpResponse.urlRequest = urlRequest;
    httpResponse.httpUrlResponse = httpUrlResponse;
    httpResponse.error = error;
    httpResponse.body = body;

    return httpResponse;

}

+ (NSString *) convertErrorMessage:(id)body {
    
    if (body && ![body isKindOfClass:[NSDictionary class]])
        return @"";
    
    return [NSString stringWithFormat:@"code:%@, %@", [body objectForKey:@"code"], [body objectForKey:@"message"]];
}

- (BOOL) success {

    if (!httpUrlResponse) {
        return NO;
    }

    return (httpUrlResponse.statusCode >= 200 && httpUrlResponse.statusCode < 300);

}

@end

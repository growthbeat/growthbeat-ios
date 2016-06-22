//
//  GBHttpClient.m
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2014/06/12.
//  Copyright (c) 2014 SIROK, Inc. All rights reserved.
//

#import "GBHttpClient.h"
#import "Growthbeat.h"

@implementation GBHttpClient

@synthesize baseUrl;
@synthesize timeout;

- (instancetype) init {
    self = [super init];
    if (self) {
        self.baseUrl = nil;
        self.timeout = 0;
    }
    return self;
}

- (instancetype) initWithBaseUrl:(NSURL *)initialBaseUrl timeout:(NSTimeInterval)initialTimeout {
    self = [super init];
    if (self) {
        self.baseUrl = initialBaseUrl;
        self.timeout = initialTimeout;
    }
    return self;
}

- (GBHttpResponse *) httpRequest:(GBHttpRequest *)httpRequest {

    if (!baseUrl) {
        [[[Growthbeat sharedInstance] logger] error:@"GBHttpClient's baseUrl is not set."];
        return nil;
    }

    NSURLRequest *urlRequest = [httpRequest urlRequestWithBaseUrl:baseUrl];
    if ([urlRequest isKindOfClass:[NSMutableURLRequest class]] && timeout > 0) {
        ((NSMutableURLRequest *)urlRequest).timeoutInterval = timeout;
    }

    NSURLResponse *urlResponse = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&error];

    id body = nil;
    if (data) {
        body = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    }

    NSHTTPURLResponse *httpUrlResponse = nil;
    if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        httpUrlResponse = (NSHTTPURLResponse *)urlResponse;
    }

    return [GBHttpResponse instanceWithUrlRequest:urlRequest httpUrlResponse:httpUrlResponse error:error body:body];

}

@end

//
//  GLFingerprintReceiver.m
//  GrowthLink
//
//  Created by TABATAKATSUTOSHI on 2015/09/09.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GLFingerprintReceiver.h"
#import <Growthbeat/GBHttpUtils.h>

@interface GLFingerprintReceiver () {

    UIWebView *webView;
    void (^completion)(NSString *fingerprintParameters);

}

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) void (^completion)(NSString *fingerprintParameters);

@end

@implementation GLFingerprintReceiver

@synthesize webView;
@synthesize completion;

- (id) init {
    self = [super init];
    if (self) {
        self.webView = [[UIWebView alloc] init];
        webView.delegate = self;
        webView.hidden = YES;
    }
    return self;
}

- (void) getFingerprintParametersWithFingerprintUrl:(NSString *)fingerprintUrl completion:(void (^)(NSString *fingerprintParameters))newCompletion {

    self.completion = newCompletion;

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }

    [webView setFrame:window.frame];
    [window addSubview:webView];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:fingerprintUrl]];
    [webView loadRequest:urlRequest];

}

#pragma mark --
#pragma mark UIWebViewDelegate

- (BOOL) webView:(UIWebView *)argWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    if (![request.URL.scheme isEqualToString:@"native"]) {
        return YES;
    }

    if ([request.URL.host isEqualToString:@"fingerprint"]) {
        NSDictionary *query = [GBHttpUtils dictionaryWithQueryString:request.URL.query];
        NSString *fingerprintParameters = [query valueForKey:@"fingerprintParameters"];
        if (completion) {
            completion(fingerprintParameters);
            self.completion = nil;
        }
        [webView removeFromSuperview];
    }

    return NO;

}

@end

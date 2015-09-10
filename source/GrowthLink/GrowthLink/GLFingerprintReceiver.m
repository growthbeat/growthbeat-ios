//
//  FingerprintUtil.m
//  GrowthLink
//
//  Created by TABATAKATSUTOSHI on 2015/09/09.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GLFingerprintReceiver.h"
#import <Growthbeat/GBHttpUtils.h>

@implementation GLFingerprintReceiver{
    
    UIWebView* webView;
    void (^completion)(NSString *fingerprintParameters);
    
}

- (void) getFingerprintParametersWithFingerprintUrl:(NSString *)fingerprintUrl completion:(void(^)(NSString *fingerprintParameters))newCompletion {
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window == nil) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    
    completion = newCompletion;
    webView = [[UIWebView alloc] initWithFrame:window.frame];
    webView.delegate = self;
    webView.hidden = NO;
    [window addSubview:webView];
    NSURL *websiteUrl = [NSURL URLWithString:fingerprintUrl];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
    [webView loadRequest:urlRequest];
    [window makeKeyAndVisible];
    
}

- (BOOL) webView:(UIWebView *)argWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.scheme isEqualToString:@"native"]) {
        if ([request.URL.host isEqualToString:@"fingerprint"]) {
            NSDictionary *dict = [GBHttpUtils dictionaryWithQueryString:request.URL.query];
            NSString *fingerprint = [dict valueForKey:@"fingerprintParameters"];
            if (completion) {
                completion(fingerprint);
            }
            [webView removeFromSuperview];
        }
        return NO;
    } else {
        return YES;
    }
}

@end

//
//  FingerprintUtil.m
//  GrowthLink
//
//  Created by TABATAKATSUTOSHI on 2015/09/09.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Fingerprint.h"

@implementation Fingerprint{
    UIWebView* webView;
    void (^callback)(NSString *fingerprintParameters);
}

- (void) getFingerPrint:(UIWindow *)window fingerprintUrl:(NSString*)fingerprintUrl argBlock:(void(^)(NSString *fingerprintParameters))argBlock{
    callback = argBlock;
    webView = [[UIWebView alloc] initWithFrame:window.frame];
    webView.delegate = self;
    webView.hidden = NO;
    [window addSubview:webView];
    NSURL *websiteUrl = [NSURL URLWithString:fingerprintUrl];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
    [webView loadRequest:urlRequest];
    [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
}

- (BOOL) webView:(UIWebView *)argWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.scheme isEqualToString:@"native"]) {
        if ([request.URL.host isEqualToString:@"fingerprint"]) {
            NSDictionary *dict = request.URL.dictionaryFromQueryString;
            NSString *fingerprint = [dict valueForKey:@"fingerprintParameters"];
            if (callback) {
                callback(fingerprint);
            }
            [webView removeFromSuperview];
        }
        return NO;
    } else {
        return YES;
    }
}

@end

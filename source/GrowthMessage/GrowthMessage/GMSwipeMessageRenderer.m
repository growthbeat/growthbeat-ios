//
//  GMSwipeMessageRenderer.m
//  GrowthMessage
//
//  Created by 田村 俊太郎 on 2015/07/14.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMSwipeMessageRenderer.h"

static NSTimeInterval const kGMSwipeMessageRendererImageDownloadTimeout = 10;

@interface GMSwipeMessageRenderer () {
    
    NSMutableDictionary *boundButtons;
    NSMutableDictionary *cachedImages;
    UIView *backgroundView;
    UIActivityIndicatorView *activityIndicatorView;
    
}

@property (nonatomic, strong) NSMutableDictionary *boundButtons;
@property (nonatomic, strong) NSMutableDictionary *cachedImages;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation GMSwipeMessageRenderer

@synthesize swipeMessage;
@synthesize delegate;
@synthesize boundButtons;
@synthesize cachedImages;
@synthesize backgroundView;
@synthesize activityIndicatorView;

- (instancetype) initWithSwipeMessage:(GMSwipeMessage *)newSwipeMessage {
    self = [super init];
    if (self) {
        self.swipeMessage = newSwipeMessage;
        self.boundButtons = [NSMutableDictionary dictionary];
        self.cachedImages = [NSMutableDictionary dictionary];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
    return self;
}

- (void) show {
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    if (!self.backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:window.frame];
        backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [window addSubview:backgroundView];
    }
    
    for (UIView *subview in backgroundView.subviews) {
        [subview removeFromSuperview];
    }

}

@end

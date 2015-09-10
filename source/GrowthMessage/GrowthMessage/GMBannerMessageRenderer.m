//
//  GMBannerMessageRenderer.m
//  GrowthMessage
//
//  Created by Baekwoo Chung on 2015/06/02.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMBannerMessageRenderer.h"
#import "GMScreenButton.h"
#import "GMCloseButton.h"
#import "GMImageButton.h"

static NSTimeInterval const kGMBannerMessageRendererImageDownloadTimeout = 10;
static NSInteger const kGMBannerMessageRendererImageHeight = 50;
static NSInteger const kGMBannerMessageRendererCloseButtonHeight = 50;
static NSInteger const kGMBannerMessageRendererMargin = 10;
static NSInteger const kGMBannerMessageRendererCloseButtonLeftRightPadding = 10;
static NSInteger const kGMBannerMessageRendererCloseButtonTopBottomPadding = kGMBannerMessageRendererCloseButtonLeftRightPadding + 5;
static NSInteger const kGMBannerMessageRendererStatusBarHeight = 20;
static CGFloat const kGMBannerMessageRendererTitleFontSize = 10;
static CGFloat const kGMBannerMessageRendererTextFontSize = 12;

@interface GMBannerMessageRenderer () {

    NSMutableDictionary *boundButtons;
    NSMutableDictionary *cachedImages;
    UIView *baseView;

}

@property (nonatomic, strong) NSMutableDictionary *boundButtons;
@property (nonatomic, strong) NSMutableDictionary *cachedImages;
@property (nonatomic, strong) UIView *baseView;

@end

@implementation GMBannerMessageRenderer

@synthesize bannerMessage;
@synthesize delegate;
@synthesize boundButtons;
@synthesize cachedImages;
@synthesize baseView;

- (instancetype) initWithBannerMessage:(GMBannerMessage *)newBannerMessage {
    self = [super init];
    if (self) {
        self.bannerMessage = newBannerMessage;
        self.boundButtons = [NSMutableDictionary dictionary];
        self.cachedImages = [NSMutableDictionary dictionary];
    }

    self.baseView = [[UIView alloc] init];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(bannerMessage.duration * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self close];
    });

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

    return self;
}

- (void) show {

    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];

    for (UIView *subview in self.baseView.subviews) {
        [subview removeFromSuperview];
    }
    [baseView removeFromSuperview];

    if (!self.baseView) {
        return;
    }

    [self cacheImages:^{

        CGFloat width = 0;
        CGFloat height = 0;

        switch (bannerMessage.bannerType) {
            case GMBannerMessageTypeOnlyImage: {
                width = MIN(window.frame.size.width, window.frame.size.height);
                height = width / bannerMessage.picture.width * bannerMessage.picture.height;
                CGSize size = CGSizeMake(width, height);
                [self generateBaseViewWithSize:size];
                [self showScreenButton:size];
                [self showCloseButton:size];
                break;
            }
            case GMBannerMessageTypeImageText: {
                width = MIN(window.frame.size.width, window.frame.size.height);
                height = kGMBannerMessageRendererImageHeight + kGMBannerMessageRendererMargin * 2;
                CGSize size = CGSizeMake(width, height);
                [self generateBaseViewWithSize:size];
                [self showImage];
                [self showText];
                [self showScreenLink];
                [self showCloseButton:size];
                break;
            }
            default:
                break;
        }
    }];
}

- (void) showScreenButton:(CGSize)size {

    GMScreenButton *screenButton = [[self extractButtonsWithType:GMButtonTypeScreen] lastObject];

    if (!screenButton) {
        return;
    }

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[cachedImages objectForKey:bannerMessage.picture.url] forState:UIControlStateNormal];

    button.frame = CGRectMake(0, 0, size.width, size.height);
    button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:button];

    [boundButtons setObject:screenButton forKey:[NSValue valueWithNonretainedObject:button]];

}

- (void) showScreenLink {

    GMScreenButton *screenButton = [[self extractButtonsWithType:GMButtonTypeScreen] lastObject];

    if (!screenButton) {
        return;
    }

    UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(tapButton:) ];
    [baseView addGestureRecognizer:singleFingerTap];
    [boundButtons setObject:screenButton forKey:[NSValue valueWithNonretainedObject:singleFingerTap]];
}


- (void) showImage {

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kGMBannerMessageRendererMargin, kGMBannerMessageRendererMargin, kGMBannerMessageRendererImageHeight, kGMBannerMessageRendererImageHeight)];
    UIImage *image = [cachedImages objectForKey:bannerMessage.picture.url];

    imageView.image = image;
    [baseView addSubview:imageView];

}

- (void) showText {

    CGFloat width = 0;
    CGFloat left = kGMBannerMessageRendererImageHeight + (kGMBannerMessageRendererMargin * 2);
    CGFloat top = kGMBannerMessageRendererMargin;
    CGFloat height = kGMBannerMessageRendererImageHeight / 2;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f ) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        width = window.frame.size.width - left - (kGMBannerMessageRendererMargin * 3);
    } else {
        width = baseView.frame.size.width - left - (kGMBannerMessageRendererMargin * 3);
    }

    if ([[self extractButtonsWithType:GMButtonTypeClose] lastObject]) {
        width -= (kGMBannerMessageRendererCloseButtonHeight - (kGMBannerMessageRendererCloseButtonTopBottomPadding * 3)) + kGMBannerMessageRendererMargin;
    }

    UIView *labelView = [[UIView alloc] initWithFrame:CGRectMake(left, top + 2, width, height)];

    UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    captionLabel.text = bannerMessage.caption;
    captionLabel.font = [UIFont boldSystemFontOfSize:kGMBannerMessageRendererTitleFontSize];
    captionLabel.textColor = [UIColor whiteColor];
    captionLabel.backgroundColor = [UIColor clearColor];
    captionLabel.minimumScaleFactor = 10;
    [labelView addSubview:captionLabel];

    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (top + height - kGMBannerMessageRendererMargin - 4), width, height)];
    textLabel.text = bannerMessage.text;
    textLabel.font = [UIFont systemFontOfSize:kGMBannerMessageRendererTextFontSize];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.backgroundColor = [UIColor clearColor];
    [labelView addSubview:textLabel];

    [baseView addSubview:labelView];

}

- (void) showCloseButton:(CGSize)size {

    GMCloseButton *closeButton = [[self extractButtonsWithType:GMButtonTypeClose] lastObject];

    if (!closeButton) {
        return;
    }

    CGFloat left = size.width - kGMBannerMessageRendererMargin - kGMBannerMessageRendererCloseButtonHeight;
    CGFloat top = (size.height - kGMBannerMessageRendererCloseButtonHeight) / 2;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    [button setImage:[cachedImages objectForKey:closeButton.picture.url] forState:UIControlStateNormal];

    button.frame = CGRectMake((left + (kGMBannerMessageRendererCloseButtonLeftRightPadding * 2)), top, (kGMBannerMessageRendererCloseButtonHeight - kGMBannerMessageRendererCloseButtonLeftRightPadding), kGMBannerMessageRendererCloseButtonHeight);

    button.contentEdgeInsets = UIEdgeInsetsMake(kGMBannerMessageRendererCloseButtonTopBottomPadding, kGMBannerMessageRendererCloseButtonLeftRightPadding, kGMBannerMessageRendererCloseButtonTopBottomPadding, kGMBannerMessageRendererCloseButtonLeftRightPadding);

    [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:button];
    [boundButtons setObject:closeButton forKey:[NSValue valueWithNonretainedObject:button]];

}

- (void) generateBaseViewWithSize:(CGSize)size {

    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];

    self.baseView = [[UIView alloc] init];
    baseView.backgroundColor = [UIColor colorWithWhite:0.12f alpha:0.92f];

    CGFloat left = (window.frame.size.width - size.width) / 2;
    CGFloat top = (bannerMessage.position == GMBannerMessagePositionTop) ? kGMBannerMessageRendererStatusBarHeight : (window.frame.size.height - size.height);
    CGFloat width = size.width;
    CGFloat height = size.height;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f ) {

        if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft ||
            [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight ||
            [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortraitUpsideDown) {

            width = size.height;
            height = size.width;

            switch ([UIApplication sharedApplication].statusBarOrientation) {
                case UIDeviceOrientationLandscapeLeft:
                    baseView.transform = CGAffineTransformMakeRotation(M_PI / 2);
                    left = ((bannerMessage.position == GMBannerMessagePositionTop) ? (window.frame.size.width - size.height) - kGMBannerMessageRendererStatusBarHeight : 0);
                    top = (window.frame.size.height - size.width) / 2;
                    break;
                case UIDeviceOrientationLandscapeRight:
                    baseView.transform = CGAffineTransformMakeRotation(M_PI / -2);
                    left = ((bannerMessage.position == GMBannerMessagePositionTop) ? kGMBannerMessageRendererStatusBarHeight : (window.frame.size.width - size.height));
                    top = (window.frame.size.height - size.width) / 2;
                    break;
                case UIDeviceOrientationPortraitUpsideDown:
                    baseView.transform = CGAffineTransformMakeRotation(M_PI * 1);
                    left = (window.frame.size.width - size.height) / 2;
                    top = ((bannerMessage.position == GMBannerMessagePositionTop) ? (window.frame.size.height - size.height) : 0);
                    break;
                default:
                    break;
            }
        }

    } else {
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationPortrait:
                if (bannerMessage.position != GMBannerMessagePositionTop) {
                    top = window.frame.size.height - size.height;
                }
                break;
            case UIInterfaceOrientationLandscapeRight:
            case UIInterfaceOrientationLandscapeLeft:
                if (bannerMessage.position == GMBannerMessagePositionTop) {
                    top = 0;
                } else {
                    top = window.frame.size.height - size.height;
                }
                break;
            default:
                break;
        }
    }

    baseView.frame = CGRectMake(left, top, width, height);
    [window addSubview:baseView];

}

- (NSArray *) extractButtonsWithType:(GMButtonType)type {

    NSMutableArray *buttons = [NSMutableArray array];

    for (GMButton *button in bannerMessage.buttons) {
        if (button.type == type) {
            [buttons addObject:button];
        }
    }

    return buttons;

}

- (void) cacheImages:(void (^)(void))callback {

    NSMutableArray *urlStrings = [NSMutableArray array];

    if (bannerMessage.picture.url) {
        [urlStrings addObject:bannerMessage.picture.url];
    }

    for (GMButton *button in bannerMessage.buttons) {
        switch (button.type) {
            case GMButtonTypeImage:
                if (((GMImageButton *)button).picture.url) {
                    [urlStrings addObject:((GMImageButton *)button).picture.url];
                }
                break;
            case GMButtonTypeClose:
                if (((GMCloseButton *)button).picture.url) {
                    [urlStrings addObject:((GMCloseButton *)button).picture.url];
                }
                break;
            default:
                continue;
        }
    }

    for (NSString *urlString in [urlStrings objectEnumerator]) {
        [self cacheImageWithUrlString:urlString completion:^(NSString *urlString){

            [urlStrings removeObject:urlString];
            if (![cachedImages objectForKey:urlString]) {
                [self.baseView removeFromSuperview];
                self.baseView = nil;
            }

            if ([urlStrings count] == 0 && callback) {
                callback();
            }

        }];
    }

}

- (void) cacheImageWithUrlString:(NSString *)urlString completion:(void (^)(NSString *urlString))completion {

    if ([cachedImages objectForKey:urlString]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(urlString);
            }
        });
        return;
    }

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kGMBannerMessageRendererImageDownloadTimeout];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        if (!data || error) {
            if (completion) {
                completion(urlString);
            }
            return;
        }

        UIImage *image = [UIImage imageWithData:data];
        if (image) {
            [cachedImages setObject:image forKey:urlString];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(urlString);
            }
        });

    }];

}

- (void) tapButton:(id)sender {

    GMButton *button = [boundButtons objectForKey:[NSValue valueWithNonretainedObject:sender]];

    [self.baseView removeFromSuperview];
    self.baseView = nil;
    self.boundButtons = nil;

    [delegate clickedButton:button message:bannerMessage];

    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void) close {

    [self.baseView removeFromSuperview];
    self.baseView = nil;
    self.boundButtons = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

@end

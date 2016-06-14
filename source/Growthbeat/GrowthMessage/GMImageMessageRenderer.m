//
//  GMImageMessageRenderer.m
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/04/21.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMImageMessageRenderer.h"
#import "GMScreenButton.h"
#import "GMCloseButton.h"
#import "GMImageButton.h"
#import "GBUtils.h"
#import "GBViewUtils.h"

static NSTimeInterval const kGMImageMessageRendererImageDownloadTimeout = 10;

@interface GMImageMessageRenderer () {

    NSMutableDictionary *boundButtons;
    NSMutableDictionary *cachedImages;
    UIView *backgroundView;
    UIActivityIndicatorView *activityIndicatorView;
    CGFloat defaultWidth;
    CGFloat defaultHeight;
    CGFloat imageButtonWidthMax;
    CGFloat imageButtonHeightMax;
    CGFloat closeButtonSizeMax;
}

@property (nonatomic, strong) NSMutableDictionary *boundButtons;
@property (nonatomic, strong) NSMutableDictionary *cachedImages;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation GMImageMessageRenderer

@synthesize imageMessage;
@synthesize delegate;
@synthesize boundButtons;
@synthesize cachedImages;
@synthesize backgroundView;
@synthesize activityIndicatorView;

- (instancetype) initWithImageMessage:(GMImageMessage *)newImageMessage {
    self = [super init];
    if (self) {
        self.imageMessage = newImageMessage;
        self.boundButtons = [NSMutableDictionary dictionary];
        self.cachedImages = [NSMutableDictionary dictionary];
        defaultWidth = 280.f;
        defaultHeight = 448.f;
        imageButtonWidthMax = 280.f;
        imageButtonHeightMax = 48.f;
        closeButtonSizeMax = 64.f;
        if (newImageMessage.task.orientation == GMMessageOrientationHorizontal) {
            defaultWidth = 448.f;
            defaultHeight = 280.f;
            imageButtonWidthMax = 448.f;
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];

    return self;
}

- (void) show {

    UIWindow *window = [GBViewUtils getWindow];

    if (!self.backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:window.frame];
        backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [window addSubview:backgroundView];
    }

    for (UIView *subview in backgroundView.subviews) {
        [subview removeFromSuperview];
    }
    UIView *baseView = [[UIView alloc] initWithFrame:backgroundView.frame];
    baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [backgroundView addSubview:baseView];

    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.frame = baseView.frame;
    activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [activityIndicatorView startAnimating];
    [baseView addSubview:activityIndicatorView];

    CGFloat screenWidth = window.frame.size.width;
    CGFloat screenHeight = window.frame.size.height;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f &&
        ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft ||
        [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight ||
        [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortraitUpsideDown)) {

        screenWidth = window.frame.size.height;
        screenHeight = window.frame.size.width;

        CGRect frame = [UIScreen mainScreen].applicationFrame;
        baseView.center = CGPointMake(CGRectGetWidth(frame) * 0.5f, CGRectGetHeight(frame) * 0.5f);

        CGRect bounds;
        bounds.origin = CGPointZero;
        bounds.size.width = CGRectGetHeight(frame);
        bounds.size.height = CGRectGetWidth(frame);
        baseView.bounds = bounds;

        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIDeviceOrientationLandscapeLeft:
                baseView.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
                break;
            case UIDeviceOrientationLandscapeRight:
                baseView.transform = CGAffineTransformMakeRotation(M_PI * -0.5);
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                baseView.transform = CGAffineTransformMakeRotation(M_PI * 1);
                break;
            default:
                break;
        }
    }

    CGFloat availableWidth = MIN(imageMessage.picture.width, defaultWidth);
    CGFloat availableHeight = MIN(imageMessage.picture.height, defaultHeight);
    CGFloat ratio = MIN(availableWidth / imageMessage.picture.width, availableHeight / imageMessage.picture.height);

    CGFloat width = imageMessage.picture.width * ratio;
    CGFloat height = imageMessage.picture.height * ratio;
    CGFloat left = (screenWidth - width) / 2;
    CGFloat top = (screenHeight - height) / 2;

    CGRect rect = CGRectMake(left, top, width, height);

    [self cacheImages:^{

        [self showImageWithView:baseView rect:rect ratio:ratio];
        [self showScreenButtonWithView:baseView rect:rect ratio:ratio];
        [self showImageButtonsWithView:baseView rect:rect ratio:ratio];
        [self showCloseButtonWithView:baseView rect:rect ratio:ratio];

        self.activityIndicatorView.hidden = YES;

    }];

}

- (void) showImageWithView:view rect:(CGRect)rect ratio:(CGFloat)ratio {

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];

    imageView.image = [cachedImages objectForKey:imageMessage.picture.url];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = YES;
    [view addSubview:imageView];

}

- (void) showScreenButtonWithView:(UIView *)view rect:(CGRect)rect ratio:(CGFloat)ratio {

    GMScreenButton *screenButton = [[self extractButtonsWithType:GMButtonTypeScreen] lastObject];

    if (!screenButton) {
        return;
    }

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[cachedImages objectForKey:imageMessage.picture.url] forState:UIControlStateNormal];
    button.contentMode = UIViewContentModeScaleAspectFit;
    button.frame = rect;
    [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];

    [boundButtons setObject:screenButton forKey:[NSValue valueWithNonretainedObject:button]];

}

- (void) showImageButtonsWithView:(UIView *)view rect:(CGRect)rect ratio:(CGFloat)ratio {

    NSArray *imageButtons = [self extractButtonsWithType:GMButtonTypeImage];

    CGFloat top = rect.origin.y + rect.size.height;

    for (GMImageButton *imageButton in [imageButtons reverseObjectEnumerator]) {
        
        CGFloat availableWidth = MIN(imageButton.picture.width * ratio, imageButtonWidthMax);
        CGFloat availableHeight = MIN(imageButton.picture.height * ratio, imageButtonHeightMax);
        CGFloat sizeRatio = MIN(availableWidth / imageButton.picture.width, availableHeight / imageButton.picture.height);

        CGFloat width = imageButton.picture.width * sizeRatio;
        CGFloat height = imageButton.picture.height * sizeRatio;
        CGFloat left = rect.origin.x + (rect.size.width - width) / 2;
        top -= height;

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[cachedImages objectForKey:imageButton.picture.url] forState:UIControlStateNormal];
        button.contentMode = UIViewContentModeScaleAspectFit;
        button.frame = CGRectMake(left, top, width, height);
        [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];

        [boundButtons setObject:imageButton forKey:[NSValue valueWithNonretainedObject:button]];

    }

}

- (void) showCloseButtonWithView:(UIView *)view rect:(CGRect)rect ratio:(CGFloat)ratio {

    GMCloseButton *closeButton = [[self extractButtonsWithType:GMButtonTypeClose] lastObject];

    if (!closeButton) {
        return;
    }
    
    CGFloat availableWidth = MIN(closeButton.picture.width, closeButtonSizeMax);
    CGFloat availableHeight = MIN(closeButton.picture.height, closeButtonSizeMax);
    CGFloat sizeRatio = MIN(availableWidth / closeButton.picture.width, availableHeight / closeButton.picture.height);
    ratio = ratio * sizeRatio;
    
    CGFloat width = closeButton.picture.width * ratio;
    CGFloat height = closeButton.picture.height * ratio;
    CGFloat left = rect.origin.x + rect.size.width - width - 8;
    CGFloat top = rect.origin.y + 8;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[cachedImages objectForKey:closeButton.picture.url] forState:UIControlStateNormal];
    button.contentMode = UIViewContentModeScaleAspectFit;
    button.frame = CGRectMake(left, top, width, height);
    [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];

    [boundButtons setObject:closeButton forKey:[NSValue valueWithNonretainedObject:button]];

}

- (NSArray *) extractButtonsWithType:(GMButtonType)type {

    NSMutableArray *buttons = [NSMutableArray array];

    for (GMButton *button in imageMessage.buttons) {
        if (button.type == type) {
            [buttons addObject:button];
        }
    }

    return buttons;

}

- (void) cacheImages:(void (^)(void))callback {

    NSMutableArray *urlStrings = [NSMutableArray array];

    if (imageMessage.picture.url) {
        [urlStrings addObject:imageMessage.picture.url];
    }

    for (GMButton *button in imageMessage.buttons) {
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
                [self.backgroundView removeFromSuperview];
                self.backgroundView = nil;
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

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kGMImageMessageRendererImageDownloadTimeout];
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

    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    self.boundButtons = nil;

    [delegate clickedButton:button message:imageMessage];

    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

@end

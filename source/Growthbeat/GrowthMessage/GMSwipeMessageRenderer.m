//
//  GMSwipeMessageRenderer.m
//  GrowthMessage
//
//  Created by 田村 俊太郎 on 2015/07/14.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMSwipeMessageRenderer.h"
#import "GMPicture.h"
#import "GMCloseButton.h"
#import "GMImageButton.h"
#import "GBViewUtils.h"

static NSTimeInterval const kGMSwipeMessageRendererImageDownloadTimeout = 10;

@interface GMSwipeMessageRenderer () {

    NSMutableDictionary *boundButtons;
    NSMutableDictionary *cachedImages;
    UIView *backgroundView;
    UIActivityIndicatorView *activityIndicatorView;
    CGFloat defaultWidth;
    CGFloat defaultHeight;
    CGFloat pagingHeight;
    CGFloat imageButtonWidthMax;
    CGFloat imageButtonHeightMax;
    CGFloat closeButtonSizeMax;

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
@synthesize scrollView;
@synthesize pageControl;

- (instancetype) initWithSwipeMessage:(GMSwipeMessage *)newSwipeMessage {
    self = [super init];
    if (self) {
        self.swipeMessage = newSwipeMessage;
        self.boundButtons = [NSMutableDictionary dictionary];
        self.cachedImages = [NSMutableDictionary dictionary];
        defaultWidth = 280.f;
        defaultHeight = 448.f;
        imageButtonWidthMax = 280.f;
        imageButtonHeightMax = 48.f;
        closeButtonSizeMax = 64.f;
        pagingHeight = 16.f;
        if (newSwipeMessage.task.orientation == GMMessageOrientationHorizontal) {
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

    CGFloat left = (screenWidth - defaultWidth) / 2;
    CGFloat top = (screenHeight - defaultHeight) / 2;
    
    CGRect rect = CGRectMake(left, top, defaultWidth, defaultHeight);
    
    [self showScrollView:baseView rect:rect];
    [self showPageControlWithView:baseView rect:rect];

    [self cacheImages:^{

        [self showImageWithView:scrollView rect:rect];
        switch (swipeMessage.swipeType) {
            case GMSwipeMessageTypeOneButton:
                [self showImageButtonWithView:baseView rect:rect];
                break;
            case GMSwipeMessageTypeImageOnly:
            default:
                break;
        }
        [self showCloseButtonWithView:baseView rect:rect];

        self.activityIndicatorView.hidden = YES;

    }];

}

- (void) showScrollView:view rect:(CGRect)rect {

    scrollView = [[UIScrollView alloc] initWithFrame:rect];

    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.userInteractionEnabled = YES;
    [scrollView setContentSize:CGSizeMake(([swipeMessage.swipeImages.pictures count] * rect.size.width), rect.size.height)];

    [view addSubview:scrollView];

}

- (void) scrollViewDidScroll:(UIScrollView *)_scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;

    if ((NSInteger)fmod(scrollView.contentOffset.x, pageWidth) == 0) {
        pageControl.currentPage = scrollView.contentOffset.x / pageWidth;
    }
}

- (void) showImageWithView:(UIView *)view rect:(CGRect)rect {

    CGFloat heightOfImageArea = rect.size.height - pagingHeight;

    for (int i = 0; i < [swipeMessage.swipeImages.pictures count]; i++) {

        GMPicture *picture = [swipeMessage.swipeImages.pictures objectAtIndex:i];

        CGFloat pictureWidth = picture.width;
        CGFloat pictureHeight = picture.height;

        CGFloat availableWidth = MIN(pictureWidth, rect.size.width);
        CGFloat availableHeight = MIN(pictureHeight, heightOfImageArea);
        CGFloat ratio = MIN(availableWidth / pictureWidth, availableHeight / pictureHeight);

        CGFloat width = pictureWidth * ratio;
        CGFloat height = pictureHeight * ratio;
        CGFloat left = (rect.size.width - width) / 2 + rect.size.width * i;
        CGFloat top = (heightOfImageArea - height) / 2;

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, width, height)];

        imageView.image = [cachedImages objectForKey:picture.url];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = YES;
        [view addSubview:imageView];

    }

}

- (void) showImageButtonWithView:(UIView *)view rect:(CGRect)rect {

    NSArray *imageButtons = [self extractButtonsWithType:GMButtonTypeImage];

    switch (swipeMessage.swipeType) {
        case GMSwipeMessageTypeImageOnly:
            return;
        case GMSwipeMessageTypeOneButton:
        {
            GMImageButton *imageButton = [imageButtons objectAtIndex:0];

            CGFloat availableWidth = MIN(imageButton.picture.width, imageButtonWidthMax);
            CGFloat availableHeight = MIN(imageButton.picture.height, imageButtonHeightMax);
            CGFloat ratio = MIN(availableWidth / imageButton.picture.width, availableHeight / imageButton.picture.height);

            CGFloat width = imageButton.picture.width * ratio;
            CGFloat height = imageButton.picture.height * ratio;
            CGFloat left = rect.origin.x + (rect.size.width - width) / 2;
            CGFloat top = rect.origin.y + rect.size.height - height - pagingHeight;

            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[cachedImages objectForKey:imageButton.picture.url] forState:UIControlStateNormal];
            button.contentMode = UIViewContentModeScaleAspectFit;
            button.frame = CGRectMake(left, top, width, height);
            [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];

            [boundButtons setObject:imageButton forKey:[NSValue valueWithNonretainedObject:button]];
            break;
        }
        default:
            break;
    }

}

- (void) showCloseButtonWithView:(UIView *)view rect:(CGRect)rect {

    GMCloseButton *closeButton = [[self extractButtonsWithType:GMButtonTypeClose] lastObject];

    if (!closeButton) {
        return;
    }

    CGFloat availableWidth = MIN(closeButton.picture.width, closeButtonSizeMax);
    CGFloat availableHeight = MIN(closeButton.picture.height, closeButtonSizeMax);
    CGFloat ratio = MIN(availableWidth / closeButton.picture.width, availableHeight / closeButton.picture.height);

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

    for (GMButton *button in swipeMessage.buttons) {
        if (button.type == type) {
            [buttons addObject:button];
        }
    }

    return buttons;

}

- (void) showPageControlWithView:(UIView *)view rect:(CGRect)rect {
    
    CGFloat width = rect.size.width;
    CGFloat height = pagingHeight;
    CGFloat left = rect.origin.x;
    CGFloat top = rect.origin.y + rect.size.height - pagingHeight;
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(left, top, width, height)];
    
    pageControl.numberOfPages = [swipeMessage.swipeImages.pictures count];
    pageControl.currentPage = 0;
    pageControl.userInteractionEnabled = NO;
    [view addSubview:pageControl];
    
}

- (void) cacheImages:(void (^)(void))callback {

    NSMutableArray *urlStrings = [NSMutableArray array];

    for (int i = 0; i < [swipeMessage.swipeImages.pictures count]; i++) {
        GMPicture *picture = [swipeMessage.swipeImages.pictures objectAtIndex:i];
        if (picture.url) {
            [urlStrings addObject:picture.url];
        }
    }

    for (GMButton *button in swipeMessage.buttons) {
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

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kGMSwipeMessageRendererImageDownloadTimeout];
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
        if (completion) {
            completion(urlString);
        }

    }];

}

- (void) tapButton:(id)sender {

    GMButton *button = [boundButtons objectForKey:[NSValue valueWithNonretainedObject:sender]];

    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    self.boundButtons = nil;

    [delegate clickedButton:button message:swipeMessage];

    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

@end

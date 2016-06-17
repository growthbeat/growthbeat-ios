//
//  GPImageMessageRenderer.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPImageMessageRenderer.h"
#import "GPScreenButton.h"
#import "GPCloseButton.h"
#import "GPImageButton.h"
#import "GBUtils.h"
#import "GBViewUtils.h"

static NSTimeInterval const kGPImageMessageRendererImageDownloadTimeout = 10;
static CGFloat const kCloseButtonSizeMax = 64.f;

@interface GPImageMessageRenderer () {
    
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

@implementation GPImageMessageRenderer

@synthesize imageMessage;
@synthesize delegate;
@synthesize boundButtons;
@synthesize cachedImages;
@synthesize backgroundView;
@synthesize activityIndicatorView;

- (instancetype) initWithImageMessage:(GPImageMessage *)newImageMessage {
    self = [super init];
    if (self) {
        self.imageMessage = newImageMessage;
        self.boundButtons = [NSMutableDictionary dictionary];
        self.cachedImages = [NSMutableDictionary dictionary];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
    return self;
}

- (void) show {
    
    UIWindow *window = [GBViewUtils getWindow];
    
    if (!self.backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:window.frame];
        backgroundView.backgroundColor = [GBViewUtils hexToUIColor: [NSString stringWithFormat:@"%lX",(long)self.imageMessage.background.color] alpha:self.imageMessage.background.opacity];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(backgroundTouched:)];
        singleFingerTap.cancelsTouchesInView = NO;
        singleFingerTap.delegate = self;
        [backgroundView addGestureRecognizer:singleFingerTap];
        [window addSubview:backgroundView];
    }
    
    for (UIView *subview in backgroundView.subviews) {
        [subview removeFromSuperview];
    }
    UIView *baseView = [[UIView alloc] initWithFrame:backgroundView.frame];
    baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [backgroundView addSubview:baseView];
    baseView.tag = 1;
    
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
    

    
    
    CGRect baseRect = CGRectMake((screenWidth - self.imageMessage.baseWidth) / 2, (screenHeight - self.imageMessage.baseHeight) / 2, self.imageMessage.baseWidth, self.imageMessage.baseHeight);
    
    [self cacheImages:^{
        
        [self showImageWithView:baseView rect:baseRect];
        [self showScreenButtonWithView:baseView rect:baseRect];
        [self showImageButtonsWithView:baseView rect:baseRect];
        [self showCloseButtonWithView:baseView rect:baseRect];
        
        self.activityIndicatorView.hidden = YES;
        
    }];
    
}

- (void) showImageWithView:view rect:(CGRect)rect {
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    
    imageView.image = [cachedImages objectForKey:imageMessage.picture.url];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = YES;
    [view addSubview:imageView];
    
}

- (void) showScreenButtonWithView:(UIView *)view rect:(CGRect)rect {
    
    GPScreenButton *screenButton = [[self extractButtonsWithType:GPButtonTypeScreen] lastObject];
    
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

- (void) showImageButtonsWithView:(UIView *)view rect:(CGRect)rect {
    
    NSArray *imageButtons = [self extractButtonsWithType:GPButtonTypeImage];
    
    CGFloat top = rect.origin.y + rect.size.height;
    
    for (GPImageButton *imageButton in [imageButtons reverseObjectEnumerator]) {
        
        CGFloat width = imageButton.baseWidth ;
        CGFloat height = imageButton.baseHeight;
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

- (void) showCloseButtonWithView:(UIView *)view rect:(CGRect)rect {
    
    GPCloseButton *closeButton = [[self extractButtonsWithType:GPButtonTypeClose] lastObject];
    
    if (!closeButton) {
        return;
    }
    
    CGFloat availableWidth = MIN(closeButton.baseWidth, kCloseButtonSizeMax);
    CGFloat availableHeight = MIN(closeButton.baseHeight, kCloseButtonSizeMax);
    CGFloat ratio = MIN(availableWidth / closeButton.baseWidth, availableHeight / closeButton.baseHeight);
    
    CGFloat width = closeButton.baseWidth * ratio;
    CGFloat height = closeButton.baseHeight * ratio;
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

- (NSArray *) extractButtonsWithType:(GPButtonType)type {
    
    NSMutableArray *buttons = [NSMutableArray array];
    
    for (GPButton *button in imageMessage.buttons) {
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
    
    for (GPButton *button in imageMessage.buttons) {
        switch (button.type) {
            case GPButtonTypeImage:
                if (((GPImageButton *)button).picture.url) {
                    [urlStrings addObject:((GPImageButton *)button).picture.url];
                }
                break;
            case GPButtonTypeClose:
                if (((GPCloseButton *)button).picture.url) {
                    [urlStrings addObject:((GPCloseButton *)button).picture.url];
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
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kGPImageMessageRendererImageDownloadTimeout];
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
    
    GPButton *button = [boundButtons objectForKey:[NSValue valueWithNonretainedObject:sender]];
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    self.boundButtons = nil;
    
    [delegate clickedButton:button message:imageMessage];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)backgroundTouched:(UITapGestureRecognizer *)recognizer {
    if (!imageMessage.background.outsideClose) {
        return;
    }
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    self.boundButtons = nil;
    
    [delegate backgroundTouched:imageMessage];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view.tag != 1)
    {
        return false;
    }
    return true;
}


@end

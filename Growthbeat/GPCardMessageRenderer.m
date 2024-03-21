//
//  GPImageMessageRenderer.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GPCardMessageRenderer.h>
#import <Growthbeat/GPScreenButton.h>
#import <Growthbeat/GPCloseButton.h>
#import <Growthbeat/GPImageButton.h>
#import <Growthbeat/GBUtils.h>
#import <Growthbeat/GBViewUtils.h>
#import <Growthbeat/GrowthPush.h>
#import <Growthbeat/GPShowMessageHandler.h>
#import <Growthbeat/GPPictureUtils.h>

static NSTimeInterval const kGPImageMessageRendererImageDownloadTimeout = 10;
static NSInteger const kGPCloseButtonPadding = 8;
static NSInteger const kGPBackgroundTagId = 9999;

@interface GPCardMessageRenderer () {
    
    NSMutableDictionary *boundButtons;
    NSMutableDictionary *cachedImages;
    UIView *backgroundView;
    BOOL alreadyRender;
    
}

@property (nonatomic, strong) NSMutableDictionary *boundButtons;
@property (nonatomic, strong) NSMutableDictionary *cachedImages;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, assign) BOOL alreadyRender;

@end

@implementation GPCardMessageRenderer

@synthesize cardMessage;
@synthesize delegate;
@synthesize boundButtons;
@synthesize cachedImages;
@synthesize backgroundView;
@synthesize alreadyRender;

- (instancetype) initWithCardMessage:(GPCardMessage *)newCardMessage {
    self = [super init];
    if (self) {
        self.cardMessage = newCardMessage;
        self.boundButtons = [NSMutableDictionary dictionary];
        self.cachedImages = [NSMutableDictionary dictionary];
        self.alreadyRender = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
    return self;
}

- (void) show {
    
    UIWindow *window = [GBViewUtils getWindow];
    
    if (!self.backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:window.frame];
        backgroundView.backgroundColor = [GBViewUtils hexToUIColor: [NSString stringWithFormat:@"%lX",(long)self.cardMessage.background.color] alpha:self.cardMessage.background.opacity];
        backgroundView.tag = kGPBackgroundTagId;
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(backgroundTouched:)];
        [singleFingerTap setDelegate:self];
        singleFingerTap.numberOfTapsRequired = 1;
        singleFingerTap.numberOfTouchesRequired = 1;
        backgroundView.userInteractionEnabled = true;
        [backgroundView addGestureRecognizer:singleFingerTap];

    }
    
    for (UIView *subview in backgroundView.subviews) {
        [subview removeFromSuperview];
    }
    
    UIView *baseView = [[UIView alloc] initWithFrame:backgroundView.frame];
    [backgroundView addSubview:baseView];
    baseView.tag = 1;
    baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGFloat screenWidth = window.frame.size.width;
    CGFloat screenHeight = window.frame.size.height;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f &&
        ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft ||
         [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight ||
         [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortraitUpsideDown)) {
            
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
            
            screenHeight = window.frame.size.width;
            screenWidth = window.frame.size.height;
            baseView.bounds = CGRectMake(0, 0, screenWidth, screenHeight);
            
        }
    
    CGSize baseSize = [GPPictureUtils calculatePictureSize:self.cardMessage.picture baseWidth:self.cardMessage.baseWidth baseHeight:self.cardMessage.baseHeight];
    NSInteger width = baseSize.width;
    NSInteger height = baseSize.height;
    
    CGRect baseRect = CGRectMake((screenWidth - width) / 2, (screenHeight - height) / 2, width, height);
    
    [self cacheImages:^{
        
        void(^renderCallback)(void) = ^() {
            dispatch_async(dispatch_get_main_queue(), ^{
                alreadyRender = YES;
                [window addSubview:backgroundView];
                
                [self showImageWithView:baseView rect:baseRect];
                [self showScreenButtonWithView:baseView rect:baseRect];
                [self showImageButtonsWithView:baseView rect:baseRect];
                [self showCloseButtonWithView:baseView rect:baseRect];
            });
        };
        
        GPShowMessageHandler *showMessageHandler = [[[GrowthPush sharedInstance] showMessageHandlers] objectForKey:cardMessage.id];
        if(!alreadyRender && showMessageHandler) {
            showMessageHandler.handleMessage(^{
                renderCallback();
            });
        } else {
            renderCallback();
        }
    }];
    
}

- (void) showImageWithView:view rect:(CGRect)rect {
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    
    imageView.image = [cachedImages objectForKey:[GBViewUtils addDensityByPictureUrl:cardMessage.picture.url]];
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
    [button setImage:[cachedImages objectForKey:[GBViewUtils addDensityByPictureUrl:cardMessage.picture.url]] forState:UIControlStateNormal];
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
        
        CGSize imageSize = [GPPictureUtils calculatePictureSize:imageButton.picture baseWidth:imageButton.baseWidth baseHeight:imageButton.baseHeight];
        CGFloat width = imageSize.width;
        CGFloat height = imageSize.height;
        CGFloat left = rect.origin.x + (rect.size.width - width) / 2;
        top -= height;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *buttonImage = [cachedImages objectForKey:[GBViewUtils addDensityByPictureUrl:imageButton.picture.url]];
        [button setImage:buttonImage forState:UIControlStateNormal];
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
    
    CGSize size = [GPPictureUtils calculatePictureSize:closeButton.picture baseWidth:closeButton.baseWidth baseHeight:closeButton.baseHeight];
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGFloat left = rect.origin.x + rect.size.width - width - kGPCloseButtonPadding;
    CGFloat top = rect.origin.y + kGPCloseButtonPadding;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[cachedImages objectForKey:[GBViewUtils addDensityByPictureUrl:closeButton.picture.url]] forState:UIControlStateNormal];
    button.contentMode = UIViewContentModeScaleAspectFit;
    button.frame = CGRectMake(left, top, width, height);
    [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    [boundButtons setObject:closeButton forKey:[NSValue valueWithNonretainedObject:button]];
    
}

- (NSArray *) extractButtonsWithType:(GPButtonType)type {
    
    NSMutableArray *buttons = [NSMutableArray array];
    
    for (GPButton *button in cardMessage.buttons) {
        if (button.type == type) {
            [buttons addObject:button];
        }
    }
    
    return buttons;
    
}

- (void) cacheImages:(void (^)(void))callback {
    
    NSMutableArray *urlStrings = [NSMutableArray array];
    
    if (cardMessage.picture.url) {
        [urlStrings addObject:[GBViewUtils addDensityByPictureUrl:cardMessage.picture.url]];
    }
    
    for (GPButton *button in cardMessage.buttons) {
        switch (button.type) {
            case GPButtonTypeImage:
                if (((GPImageButton *)button).picture.url) {
                    [urlStrings addObject:[GBViewUtils addDensityByPictureUrl:((GPImageButton *)button).picture.url]];
                }
                break;
            case GPButtonTypeClose:
                if (((GPCloseButton *)button).picture.url) {
                    [urlStrings addObject:[GBViewUtils addDensityByPictureUrl:((GPCloseButton *)button).picture.url]];
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
    
    [delegate clickedButton:button message:cardMessage];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)backgroundTouched:(UITapGestureRecognizer *)recognizer {

    if (!cardMessage.background.outsideClose || recognizer.view.tag != kGPBackgroundTagId)
        return;
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    self.boundButtons = nil;
    
    [delegate backgroundTouched:cardMessage];
    
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

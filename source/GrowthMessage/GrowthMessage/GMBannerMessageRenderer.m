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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
    return self;
}

- (void) show {
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    if (!self.baseView) {
        baseView = [[UIView alloc] init];
        [window addSubview:baseView];
    } else {
        for (UIView *subview in baseView.subviews) {
            [subview removeFromSuperview];
        }
    }
    
    CGFloat screenWidth = window.frame.size.width;
    CGFloat screenHeight = window.frame.size.height;
    CGFloat availableWidth = MIN(screenWidth, screenHeight);
    CGFloat availableHeight = 60;
    
    if (bannerMessage.bannerType == GMBannerMessageTypeOnlyImage) {
        availableWidth = MIN(bannerMessage.picture.width, MIN(screenWidth, screenHeight));
        CGFloat ratio = MIN(screenWidth, screenHeight) / bannerMessage.picture.width;
        availableHeight = bannerMessage.picture.height * ratio;
    }
    
    [self cacheImages:^ {
        
        [self showOnlyImageWithView:baseView rect:baseView.frame];
        [self showImageTextWithView:baseView rect:baseView.frame];
        [self showCloseButtonWithView:baseView rect:baseView.frame];
        
    }];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f ) {
        
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIDeviceOrientationLandscapeLeft:
                NSLog(@"1");
                baseView.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
                break;
            case UIDeviceOrientationLandscapeRight:
                NSLog(@"2");
                baseView.transform = CGAffineTransformMakeRotation(M_PI * -0.5);
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                NSLog(@"3");
                baseView.transform = CGAffineTransformMakeRotation(M_PI * 1);
                break;
            default:
                NSLog(@"4");
                baseView.transform = CGAffineTransformMakeRotation(0);
                break;
        }
    }
    
    CGRect baseRect = CGRectMake(0.0, 0.0, availableWidth, availableHeight);
    
    if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortrait) {
        baseRect.origin.y = 20;
    }
    
    baseView.frame = baseRect;
    
    if (bannerMessage.position == GMBannerMessagePositionTop)
        baseView.center = CGPointMake(screenWidth / 2, baseView.center.y);
    else
        baseView.center = CGPointMake(screenWidth / 2, screenHeight - (availableHeight / 2));
    
}

- (void) showOnlyImageWithView:view rect:(CGRect)rect {
    
    if ( bannerMessage.bannerType != GMBannerMessageTypeOnlyImage) {
        return;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[cachedImages objectForKey:bannerMessage.picture.url] forState:UIControlStateNormal];
    button.contentMode = UIViewContentModeScaleAspectFit;
    button.frame = rect;
    button.center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    GMScreenButton *screenButton = [[self extractButtonsWithType:GMButtonTypeScreen] lastObject];
    [boundButtons setObject:screenButton forKey:[NSValue valueWithNonretainedObject:button]];
    
}

- (void) showImageTextWithView:(UIView *)view rect:(CGRect)rect {
    
    if ( bannerMessage.bannerType != GMBannerMessageTypeImageText) {
        return;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIView *subView = [[UIView alloc] initWithFrame:rect];
    subView.backgroundColor = [UIColor grayColor];
    subView.center = CGPointMake(rect.size.width / 2, rect.size.height / 2);

    UIImageView *imageHolder = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    UIImage *image = [cachedImages objectForKey:bannerMessage.picture.url];
    imageHolder.image = image;
    [subView addSubview:imageHolder];
    
    UILabel *captionLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 10, 100, 20)];
    [captionLabel setBackgroundColor:[UIColor clearColor]];
    [captionLabel setText:bannerMessage.caption];
    [captionLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [subView addSubview:captionLabel];
    
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 30, 100, 20)];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setText:bannerMessage.text];
    [textLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [subView addSubview:textLabel];
    
    button.contentMode = UIViewContentModeScaleAspectFit;
    button.frame = rect;
    button.center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [button addSubview:subView];
    [view addSubview:button];
    
    GMScreenButton *screenButton = [[self extractButtonsWithType:GMButtonTypeScreen] lastObject];
    [boundButtons setObject:screenButton forKey:[NSValue valueWithNonretainedObject:button]];
    
}

- (void) showCloseButtonWithView:(UIView *)view rect:(CGRect)rect {
    
    GMCloseButton *closeButton = [[self extractButtonsWithType:GMButtonTypeClose] lastObject];
    
    if (!closeButton) {
        return;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[cachedImages objectForKey:closeButton.picture.url] forState:UIControlStateNormal];
    button.contentMode = UIViewContentModeScaleAspectFit;
    button.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
    button.center = CGPointMake(rect.size.width - 20, rect.size.height / 2);
    [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    [boundButtons setObject:closeButton forKey:[NSValue valueWithNonretainedObject:button]];
    
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
            if(![cachedImages objectForKey:urlString]) {
                [self.baseView removeFromSuperview];
                self.baseView = nil;
            }
            
            if([urlStrings count] == 0 && callback) {
                callback();
            }
            
        }];
    }
    
}

- (void) cacheImageWithUrlString:(NSString *)urlString completion:(void (^)(NSString *urlString))completion {
    
    if ([cachedImages objectForKey:urlString]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completion) {
                completion(urlString);
            }
        });
        return;
    }
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kGMBannerMessageRendererImageDownloadTimeout];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if(!data || error) {
            if(completion) {
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
    
    [self.baseView removeFromSuperview];
    self.baseView = nil;
    self.boundButtons = nil;
    
    [delegate clickedButton:button message:bannerMessage];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

@end

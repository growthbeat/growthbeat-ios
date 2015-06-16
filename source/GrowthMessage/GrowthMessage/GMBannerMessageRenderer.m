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
static NSInteger const kGMBannerMessageRendererImageHeight = 40;
static NSInteger const kGMBannerMessageRendererCloseButtonHeight = 20;
static NSInteger const kGMBannerMessageRendererMargin = 10;

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
    
    if (!self.baseView) {
        [self createBaseView];
    }
    
    [self adjustPositionWithSize:baseView.frame.size];
    
}

- (void) createBaseView {
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    self.baseView = [[UIView alloc] init];
    baseView.backgroundColor = [UIColor grayColor];
    
    [self cacheImages:^ {
        [window addSubview:baseView];
        
        CGFloat width = 0;
        CGFloat height = 0;
        switch (bannerMessage.bannerType) {
            case GMBannerMessageTypeOnlyImage:
                width = MIN(window.frame.size.width, window.frame.size.height);
                height = width / bannerMessage.picture.width * bannerMessage.picture.height;
                [self adjustPositionWithSize:CGSizeMake(width, height)];
                [self showScreenButton];
                [self showCloseButton];
                break;
            case GMBannerMessageTypeImageText:
                width = MIN(window.frame.size.width, window.frame.size.height);
                height = kGMBannerMessageRendererImageHeight + kGMBannerMessageRendererMargin * 2;
                [self adjustPositionWithSize:CGSizeMake(width, height)];
                [self showImage];
                [self showText];
                [self showCloseButton];
                break;
            default:
                break;
        }
        
    }];
    
}

- (void) showScreenButton {
    
    GMScreenButton *screenButton = [[self extractButtonsWithType:GMButtonTypeScreen] lastObject];
    
    if (!screenButton) {
        return;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[cachedImages objectForKey:bannerMessage.picture.url] forState:UIControlStateNormal];
    button.frame = baseView.frame;
    button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:button];
    
    [boundButtons setObject:screenButton forKey:[NSValue valueWithNonretainedObject:button]];
    
}

- (void) showImage {
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kGMBannerMessageRendererMargin, kGMBannerMessageRendererMargin, kGMBannerMessageRendererImageHeight, kGMBannerMessageRendererImageHeight)];
    UIImage *image = [cachedImages objectForKey:bannerMessage.picture.url];
    imageView.image = image;
    [baseView addSubview:imageView];
    
}

- (void) showText {
    
    CGFloat labelLeft = kGMBannerMessageRendererImageHeight + kGMBannerMessageRendererMargin * 2;
    CGFloat labelTop = kGMBannerMessageRendererMargin;
    CGFloat labelWidth = baseView.frame.size.width - labelLeft - kGMBannerMessageRendererMargin;
    CGFloat labelHeight = kGMBannerMessageRendererImageHeight / 2;
    
    if([[self extractButtonsWithType:GMButtonTypeClose] lastObject])
        labelWidth -= kGMBannerMessageRendererCloseButtonHeight + kGMBannerMessageRendererMargin;
    
    UILabel *captionLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelLeft, labelTop, labelWidth, labelHeight)];
    [captionLabel setText:bannerMessage.caption];
    [captionLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [baseView addSubview:captionLabel];
    
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelLeft, labelTop + labelHeight, labelWidth, labelHeight)];
    [textLabel setText:bannerMessage.text];
    [textLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [baseView addSubview:textLabel];
    
}

- (void) showCloseButton {
    
    GMCloseButton *closeButton = [[self extractButtonsWithType:GMButtonTypeClose] lastObject];
    
    if (!closeButton) {
        return;
    }
    
    CGFloat left = baseView.frame.size.width - kGMBannerMessageRendererMargin - kGMBannerMessageRendererCloseButtonHeight;
    CGFloat top = (baseView.frame.size.height - kGMBannerMessageRendererCloseButtonHeight)/2;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[cachedImages objectForKey:closeButton.picture.url] forState:UIControlStateNormal];
    button.frame = CGRectMake(left, top, kGMBannerMessageRendererCloseButtonHeight, kGMBannerMessageRendererCloseButtonHeight);
    [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:button];
    [boundButtons setObject:closeButton forKey:[NSValue valueWithNonretainedObject:button]];
    
}

- (void) adjustPositionWithSize:(CGSize)size {
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGFloat left = (window.frame.size.width - size.width)/2;
    CGFloat top = (bannerMessage.position == GMBannerMessagePositionTop) ? 0 : (window.frame.size.height - size.width);
    
    baseView.frame = CGRectMake(left, top, size.width, size.height);
    
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

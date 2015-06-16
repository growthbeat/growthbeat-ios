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
    
}

- (void) createBaseView {
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    self.baseView = [[UIView alloc] init];
    [window addSubview:baseView];
    
    CGFloat width = 0;
    CGFloat height = 0;
    switch (bannerMessage.bannerType) {
        case GMBannerMessageTypeOnlyImage:
            width = MIN(window.frame.size.width, window.frame.size.height);
            height = width / bannerMessage.picture.width * bannerMessage.picture.height;
            [self createOnlyImageBaseView];
            break;
        case GMBannerMessageTypeImageText:
            width = MIN(window.frame.size.width, window.frame.size.height);
            height = kGMBannerMessageRendererImageHeight + kGMBannerMessageRendererMargin * 2;
            [self createImageTextBaseView];
            break;
        default:
            break;
    }
    
    CGFloat left = (window.frame.size.width - width)/2;
    CGFloat top = (bannerMessage.position == GMBannerMessagePositionTop) ? 0 : (window.frame.size.height - height);
    
    baseView.frame = CGRectMake(left, top, width, height);
    baseView.backgroundColor = [UIColor grayColor];
    
}

- (void) createOnlyImageBaseView {
    
    // TODO implement
    
}

- (void) createImageTextBaseView {
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kGMBannerMessageRendererMargin, kGMBannerMessageRendererMargin, kGMBannerMessageRendererImageHeight, kGMBannerMessageRendererImageHeight)];
    UIImage *image = [cachedImages objectForKey:bannerMessage.picture.url];
    imageView.image = image;
    [baseView addSubview:imageView];
    
    CGFloat captionLabelLeft = kGMBannerMessageRendererImageHeight + kGMBannerMessageRendererMargin * 2;
    CGFloat captionLabelTop = kGMBannerMessageRendererMargin;
    CGFloat captionLabelWidth = 100;
    CGFloat captionLabelHeight = kGMBannerMessageRendererImageHeight / 2;
    UILabel *captionLabel = [[UILabel alloc]initWithFrame:CGRectMake(captionLabelLeft, captionLabelTop, captionLabelWidth, captionLabelHeight)];
    [captionLabel setBackgroundColor:[UIColor clearColor]];
    [captionLabel setText:bannerMessage.caption];
    [captionLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [baseView addSubview:captionLabel];
    
    CGFloat textLabelLeft = captionLabelLeft;
    CGFloat textLabelTop = captionLabelTop + captionLabelHeight;
    CGFloat textLabelWidth = 100;
    CGFloat textLabelHeight = kGMBannerMessageRendererImageHeight / 2;
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(textLabelLeft, textLabelTop, textLabelWidth, textLabelHeight)];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setText:bannerMessage.text];
    [textLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [baseView addSubview:textLabel];
    
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

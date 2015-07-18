//
//  GMSwipeMessageRenderer.m
//  GrowthMessage
//
//  Created by 田村 俊太郎 on 2015/07/14.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMSwipeMessageRenderer.h"
#import "GMPicture.h"

static NSTimeInterval const kGMSwipeMessageRendererImageDownloadTimeout = 10;
static NSInteger kGMSwipeMessageRendererCurrentPageNumber = 0;

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

    GMPicture *picture = [swipeMessage.pictures objectAtIndex:kGMSwipeMessageRendererCurrentPageNumber];
    CGFloat availableWidth = MIN(picture.width, screenWidth * 0.85);
    CGFloat availableHeight = MIN(picture.height, screenHeight * 0.85);
    CGFloat ratio = MIN(availableWidth / picture.width, availableHeight / picture.height);
    
    CGFloat width = picture.width * ratio;
    CGFloat height = picture.height * ratio;
    CGFloat left = (screenWidth - width) / 2;
    CGFloat top = (screenHeight - height) / 2;
    
    CGRect rect = CGRectMake(left, top, width, height);

    [self cacheImages:^{
        
        [self showImageWithView:baseView rect:rect ratio:ratio];
        [self showPageControlWithView:baseView];
        
        self.activityIndicatorView.hidden = YES;
        
    }];

    [self recognizeSwipeGesture:baseView];

}

- (void) showImageWithView:view rect:(CGRect)rect ratio:(CGFloat)ratio {
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    
    GMPicture *picture = [swipeMessage.pictures objectAtIndex:kGMSwipeMessageRendererCurrentPageNumber];
    imageView.image = [cachedImages objectForKey:picture.url];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = YES;
    [view addSubview:imageView];
    
}

- (void) showPageControlWithView:view {
    
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 450, 320, 30)];
    
    pageControl.numberOfPages = [swipeMessage.pictures count];
    pageControl.currentPage = kGMSwipeMessageRendererCurrentPageNumber;
    pageControl.userInteractionEnabled = NO;
    [view addSubview:pageControl];
    
}

- (void) cacheImages:(void (^)(void))callback {
    
    NSMutableArray *urlStrings = [NSMutableArray array];
    
    GMPicture *picture = [swipeMessage.pictures objectAtIndex:kGMSwipeMessageRendererCurrentPageNumber];
    if (picture.url) {
        [urlStrings addObject:picture.url];
    }
    
    for (NSString *urlString in [urlStrings objectEnumerator]) {
        [self cacheImageWithUrlString:urlString completion:^(NSString *urlString){
            
            [urlStrings removeObject:urlString];
            if(![cachedImages objectForKey:urlString]) {
                [self.backgroundView removeFromSuperview];
                self.backgroundView = nil;
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
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kGMSwipeMessageRendererImageDownloadTimeout];
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

- (void)recognizeSwipeGesture:view {
    
    UISwipeGestureRecognizer* swipeLeftGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft:)];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [view addGestureRecognizer:swipeLeftGesture];
    
    UISwipeGestureRecognizer* swipeRightGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipeRightGesture];
    
}

- (void)swipeLeft:(UISwipeGestureRecognizer *)sender {
    
    if (kGMSwipeMessageRendererCurrentPageNumber == [swipeMessage.pictures count] - 1)
        return;
    
    kGMSwipeMessageRendererCurrentPageNumber += 1;
    [self show];
    
}

- (void)swipeRight:(UISwipeGestureRecognizer *)sender {
    
    if (kGMSwipeMessageRendererCurrentPageNumber == 0)
        return;
    
    kGMSwipeMessageRendererCurrentPageNumber -= 1;
    [self show];
}

@end

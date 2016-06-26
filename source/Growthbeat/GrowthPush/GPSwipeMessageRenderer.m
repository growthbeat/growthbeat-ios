//
//  MPSwipeMessgeRenderer.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPSwipeMessageRenderer.h"
#import "GPPicture.h"
#import "GPCloseButton.h"
#import "GPImageButton.h"
#import "GBViewUtils.h"
#import "GrowthPush.h"


static NSTimeInterval const kGPSwipeMessageRendererImageDownloadTimeout = 10;
static CGFloat const kPagingHeight = 16.f;
static CGFloat const kCloseButtonSizeMax = 64.f;

@interface GPSwipeMessageRenderer () {
    
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

@implementation GPSwipeMessageRenderer

@synthesize swipeMessage;
@synthesize delegate;
@synthesize boundButtons;
@synthesize cachedImages;
@synthesize backgroundView;
@synthesize activityIndicatorView;
@synthesize scrollView;
@synthesize pageControl;

- (instancetype) initWithSwipeMessage:(GPSwipeMessage *)newSwipeMessage {
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
    
    UIWindow *window = [GBViewUtils getWindow];
    
    if (!self.backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:window.frame];
        backgroundView.backgroundColor = [GBViewUtils hexToUIColor:[NSString stringWithFormat:@"%ld",(long) self.swipeMessage.background.color] alpha:self.swipeMessage.background.opacity];
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
    baseView.tag = 1;
    baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [backgroundView addSubview:baseView];
    
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.frame = baseView.frame;
    activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [activityIndicatorView startAnimating];
    [baseView addSubview:activityIndicatorView];
    
    CGFloat screenWidth = window.frame.size.width;
    CGFloat screenHeight = window.frame.size.height;
    [self rotateBaseView:baseView];
    
    
    CGFloat baseWidth = self.swipeMessage.baseWidth;
    CGFloat baseHeight = self.swipeMessage.baseHeight;
    
    CGFloat rootWidth = baseWidth;
    CGFloat rootHeight = baseHeight + kPagingHeight;
    
    if (swipeMessage.swipeType == GPSwipeMessageTypeOneButton) {
        NSArray *imageButtons = [self extractButtonsWithType:GPButtonTypeImage];
        GPImageButton *imageButton = [imageButtons objectAtIndex:0];
        CGFloat availableWidth = MIN(imageButton.baseWidth, baseWidth);
        CGFloat ratio = MIN(availableWidth / imageButton.baseWidth, 1);
        CGFloat buttonHeight = imageButton.baseHeight * ratio;
        rootHeight += buttonHeight;
    }

    CGRect baseRect = CGRectMake((screenWidth - baseWidth) / 2, (screenHeight - rootHeight) / 2, self.swipeMessage.baseWidth, self.swipeMessage.baseHeight);
    
    CGRect rootRect = CGRectMake((screenWidth - rootWidth) / 2, (screenHeight - rootHeight) / 2, rootWidth, rootHeight);
    
    [self showScrollView:baseView rect:baseRect];
    [self showPageControlWithView:baseView rect:rootRect];
    
    [self cacheImages:^{
        
        void(^renderCallback)() = ^() {
            [self showImageWithView:scrollView rect:baseRect];
            switch (swipeMessage.swipeType) {
                case GPSwipeMessageTypeOneButton:
                    [self showImageButtonWithView:baseView rect:baseRect];
                    break;
                case GPSwipeMessageTypeImageOnly:
                default:
                    break;
            }
            [self showCloseButtonWithView:baseView rect:baseRect];
            
            self.activityIndicatorView.hidden = YES;
        };
        
        GPShowMessageHandler *showMessageHandler = [[[GrowthPush sharedInstance] showMessageHandlers] objectForKey:swipeMessage.id];
        if(showMessageHandler) {
            showMessageHandler.handleMessage(^{
                renderCallback();
            });
        } else {
            renderCallback();
        }
        
    }];
    
}

- (void) rotateBaseView:(UIView *)baseView {
    
    switch (swipeMessage.task.orientation) {
        case GPMessageOrientationVertical:
            switch ([UIApplication sharedApplication].statusBarOrientation) {
                case UIDeviceOrientationLandscapeLeft:
                    baseView.transform = CGAffineTransformMakeRotation(M_PI * -0.5);
                    break;
                case UIDeviceOrientationLandscapeRight:
                    baseView.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
                    break;
                default:
                    break;
            }
            break;
        case GPMessageOrientationHorizontal:
            
            switch ([UIApplication sharedApplication].statusBarOrientation) {
                case UIDeviceOrientationPortraitUpsideDown:
                case UIInterfaceOrientationPortrait:
                    baseView.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

- (void) showScrollView:view rect:(CGRect)rect {
    
    scrollView = [[UIScrollView alloc] initWithFrame:rect];
    
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.userInteractionEnabled = YES;
    [scrollView setContentSize:CGSizeMake(([swipeMessage.pictures count] * rect.size.width), rect.size.height)];
    
    [view addSubview:scrollView];
    
}

- (void) scrollViewDidScroll:(UIScrollView *)_scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    
    if ((NSInteger)fmod(scrollView.contentOffset.x, pageWidth) == 0) {
        pageControl.currentPage = scrollView.contentOffset.x / pageWidth;
    }
}

- (void) showImageWithView:(UIView *)view rect:(CGRect)rect {
    
    for (int i = 0; i < [swipeMessage.pictures count]; i++) {
        
        GPPicture *picture = [swipeMessage.pictures objectAtIndex:i];
        
        
        CGFloat width = swipeMessage.baseWidth;
        CGFloat height = swipeMessage.baseHeight;
        CGFloat left = rect.size.width * i;
        CGFloat top = 0;
        CGRect imageRect = CGRectMake(left, top, width, height);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageRect];
        
        imageView.image = [cachedImages objectForKey:[GBViewUtils addDensityByPictureUrl:picture.url]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = YES;
        [view addSubview:imageView];
        
    }
    
}

- (void) showImageButtonWithView:(UIView *)view rect:(CGRect)rect {
    
    NSArray *imageButtons = [self extractButtonsWithType:GPButtonTypeImage];
    
    switch (swipeMessage.swipeType) {
        case GPSwipeMessageTypeImageOnly:
            return;
        case GPSwipeMessageTypeOneButton:
        {
            GPImageButton *imageButton = [imageButtons objectAtIndex:0];
            
            CGFloat availableWidth = MIN(imageButton.baseWidth, rect.size.width);
            CGFloat ratio = MIN(availableWidth / imageButton.baseWidth, 1);
            
            CGFloat width = imageButton.baseWidth * ratio;
            CGFloat height = imageButton.baseHeight * ratio;
            CGFloat left = rect.origin.x + (rect.size.width - width) / 2;
            CGFloat top = rect.origin.y + rect.size.height;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[cachedImages objectForKey:[GBViewUtils addDensityByPictureUrl:imageButton.picture.url ]] forState:UIControlStateNormal];
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
    [button setImage:[cachedImages objectForKey:[GBViewUtils addDensityByPictureUrl:closeButton.picture.url]] forState:UIControlStateNormal];
    button.contentMode = UIViewContentModeScaleAspectFit;
    button.frame = CGRectMake(left, top, width, height);
    [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    [boundButtons setObject:closeButton forKey:[NSValue valueWithNonretainedObject:button]];
    
}

- (NSArray *) extractButtonsWithType:(GPButtonType)type {
    
    NSMutableArray *buttons = [NSMutableArray array];
    
    for (GPButton *button in swipeMessage.buttons) {
        if (button.type == type) {
            [buttons addObject:button];
        }
    }
    
    return buttons;
    
}

- (void) showPageControlWithView:(UIView *)view rect:(CGRect)rect {
    
    CGFloat width = rect.size.width;
    CGFloat height = kPagingHeight;
    CGFloat left = rect.origin.x;
    CGFloat top = rect.origin.y + rect.size.height - kPagingHeight;
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(left, top, width, height)];
    
    pageControl.numberOfPages = [swipeMessage.pictures count];
    pageControl.currentPage = 0;
    pageControl.userInteractionEnabled = NO;
    [view addSubview:pageControl];
    
}

- (void) cacheImages:(void (^)(void))callback {
    
    NSMutableArray *urlStrings = [NSMutableArray array];
    
    for (int i = 0; i < [swipeMessage.pictures count]; i++) {
        GPPicture *picture = [swipeMessage.pictures objectAtIndex:i];
        if (picture.url) {
            [urlStrings addObject:[GBViewUtils addDensityByPictureUrl:picture.url]];
        }
    }
    
    for (GPButton *button in swipeMessage.buttons) {
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
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kGPSwipeMessageRendererImageDownloadTimeout];
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
    
    GPButton *button = [boundButtons objectForKey:[NSValue valueWithNonretainedObject:sender]];
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    self.boundButtons = nil;
    
    [delegate clickedButton:button message:swipeMessage];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)backgroundTouched:(UITapGestureRecognizer *)recognizer {
    if (!swipeMessage.background.outsideClose) {
        return;
    }
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    self.boundButtons = nil;
    [delegate backgroundTouched:swipeMessage];
    
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

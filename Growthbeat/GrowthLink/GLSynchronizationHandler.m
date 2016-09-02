//
//  GLSynchronizationHandler.m
//  GrowthLink
//
//  Created by TABATAKATSUTOSHI on 2016/01/26.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GLSynchronizationHandler.h"
#import "GrowthLink.h"
#import "GBViewUtils.h"

@implementation GLSynchronizationHandler {
    UIViewController * safariViewController;
    NSObject* _objectForLock;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _objectForLock = [[NSObject alloc] init];
    }
    return self;
}

- (void)synchronizeByCookie:(GLSynchronization *)synchronization synchronizationUrl:(NSString *)synchronizationUrl {
    NSString *urlString = [NSString stringWithFormat:@"%@?applicationId=%@&advertisingId=%@",synchronizationUrl, [[GrowthLink sharedInstance] applicationId], [GBDeviceUtils getAdvertisingId]];
    Class SFSafariViewControllerClass = NSClassFromString(@"SFSafariViewController");
    if (SFSafariViewControllerClass) {
        safariViewController = [[SFSafariViewControllerClass alloc] initWithURL:[NSURL URLWithString:urlString]];
        
        self.window = [[UIWindow alloc] initWithFrame:[[GBViewUtils getWindow] bounds]];
        UIViewController *windowRootController = [[UIViewController alloc] init];
        self.window.rootViewController = windowRootController;
        self.window.windowLevel = UIWindowLevelNormal - 1;
        [self.window setHidden:NO];
        [self.window setAlpha:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [windowRootController addChildViewController:safariViewController];
            [windowRootController.view addSubview:safariViewController.view];
            [safariViewController didMoveToParentViewController:windowRootController];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @synchronized (_objectForLock)
                {
                    if (self.window) {
                        [safariViewController willMoveToParentViewController:nil];
                        [safariViewController.view removeFromSuperview];
                        [safariViewController removeFromParentViewController];
                        [self.window removeFromSuperview];
                        self.window = nil;
                    }
                }

            });
        });
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
    
}

- (BOOL)synchronizeByFingerprint:(GLSynchronization *)synchronization {
    if (synchronization.clickId) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"?clickId=%@", synchronization.clickId]];
        [[GrowthLink sharedInstance] handleOpenUrl:url];
        return YES;
    }
    return NO;
}


- (void)removeWindowIfExists {
    @synchronized (_objectForLock)
    {
        if (self.window) {
            [safariViewController willMoveToParentViewController:nil];
            [safariViewController.view removeFromSuperview];
            [safariViewController removeFromParentViewController];
            [self.window removeFromSuperview];
            self.window = nil;
        }
    }
}


@end


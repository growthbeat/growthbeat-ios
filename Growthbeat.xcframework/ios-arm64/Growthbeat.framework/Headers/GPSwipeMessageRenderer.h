//
//  MPSwipeMessgeRenderer.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Growthbeat/GPSwipeMessage.h>
#import <Growthbeat/GPMessageRendererDelegate.h>

@interface GPSwipeMessageRenderer : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    
    GPSwipeMessage *swipeMessage;
    UIScrollView *scrollView;
    UIPageControl *pageControl;
    
}

@property (nonatomic, strong) GPSwipeMessage *swipeMessage;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, weak) id <GPMessageRendererDelegate> delegate;

- (instancetype)initWithSwipeMessage:(GPSwipeMessage *)newSwipeMessage;
- (void)show;

@end

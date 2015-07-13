//
//  GMSwipeMessageRenderer.h
//  GrowthMessage
//
//  Created by 田村 俊太郎 on 2015/07/13.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMSwipeMessage.h"
#import "GMSwipeMessageRendererDelegate.h"

@interface GMSwipeMessageRenderer : NSObject {
    
    GMSwipeMessage *swipeMessage;
    __weak id <GMSwipeMessageRendererDelegate> delegate;
    
}

@property (nonatomic, strong) GMSwipeMessage *swipeMessage;
@property (nonatomic, weak) id <GMSwipeMessageRendererDelegate> delegate;

- (instancetype)initWithSwipeMessage:(GMSwipeMessage *)newSwipeMessage;
- (void)show;

@end

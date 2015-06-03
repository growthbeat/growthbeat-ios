//
//  GMBannerMessageRenderer.h
//  GrowthMessage
//
//  Created by Baekwoo Chung on 2015/06/02.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMBannerMessage.h"
#import "GMBannerMessageRendererDelegate.h"

@interface GMBannerMessageRenderer : NSObject {
    
    GMBannerMessage *bannerMessage;
    __weak id <GMBannerMessageRendererDelegate> delegate;
    
}

@property (nonatomic, strong) GMBannerMessage *bannerMessage;
@property (nonatomic, weak) id <GMBannerMessageRendererDelegate> delegate;

- (instancetype)initWithBannerMessage:(GMBannerMessage *)newBannerMessage;
- (void)show;

@end

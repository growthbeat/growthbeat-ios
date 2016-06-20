//
//  GPImageMessageRenderer.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPCardMessage.h"
#import "GPMessageRendererDelegate.h"

@interface GPCardMessageRenderer : NSObject <UIGestureRecognizerDelegate> {
    
    GPCardMessage *cardMessage;
    __weak id <GPMessageRendererDelegate> delegate;
    
}

@property (nonatomic, strong) GPCardMessage *cardMessage;
@property (nonatomic, weak) id <GPMessageRendererDelegate> delegate;
@property (nonatomic, copy) void(^ messageCallback)(GPMessage * message);


- (instancetype)initWithImageMessage:(GPCardMessage *)newCardMessage;
- (void)show;

@end

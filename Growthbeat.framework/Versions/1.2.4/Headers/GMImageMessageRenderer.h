//
//  GMImageMessageRenderer.h
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/04/21.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMImageMessage.h"
#import "GMMessageRendererDelegate.h"

@interface GMImageMessageRenderer : NSObject {

    GMImageMessage *imageMessage;
    __weak id <GMMessageRendererDelegate> delegate;

}

@property (nonatomic, strong) GMImageMessage *imageMessage;
@property (nonatomic, weak) id <GMMessageRendererDelegate> delegate;

- (instancetype)initWithImageMessage:(GMImageMessage *)newImageMessage;
- (void)show;

@end

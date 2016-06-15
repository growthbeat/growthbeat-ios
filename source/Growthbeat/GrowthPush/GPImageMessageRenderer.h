//
//  GPImageMessageRenderer.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPImageMessage.h"
#import "GPMessageRendererDelegate.h"

@interface GPImageMessageRenderer : NSObject {
    
    GPImageMessage *imageMessage;
    __weak id <GPMessageRendererDelegate> delegate;
    
}

@property (nonatomic, strong) GPImageMessage *imageMessage;
@property (nonatomic, weak) id <GPMessageRendererDelegate> delegate;

- (instancetype)initWithImageMessage:(GPImageMessage *)newImageMessage;
- (void)show;

@end

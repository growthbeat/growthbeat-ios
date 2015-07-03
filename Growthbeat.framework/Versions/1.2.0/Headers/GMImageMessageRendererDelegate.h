//
//  GMImageMessageRendererDelegate.h
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/04/21.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMButton.h"
#import "GMMessage.h"

@protocol GMImageMessageRendererDelegate <NSObject>

- (void)clickedButton:(GMButton *)button message:(GMMessage *)message;

@end

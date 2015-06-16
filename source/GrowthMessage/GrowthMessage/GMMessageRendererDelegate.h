//
//  GMMessageRendererDelegate.h
//  GrowthMessage
//
//  Created by Baekwoo Chung on 2015/06/02.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMButton.h"
#import "GMMessage.h"

@protocol GMMessageRendererDelegate <NSObject>

- (void)clickedButton:(GMButton *)button message:(GMMessage *)message;

@end

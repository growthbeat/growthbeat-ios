//
//  GMSwipeMessageRendererDelegate.h
//  GrowthMessage
//
//  Created by 田村 俊太郎 on 2015/07/13.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMButton.h"
#import "GMMessage.h"

@protocol GMSwipeMessageRendererDelegate <NSObject>

- (void)clickedButton:(GMButton *)button message:(GMMessage *)message;

@end

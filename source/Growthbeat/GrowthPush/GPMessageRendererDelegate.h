//
//  GPMessageRendererDelegate.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPButton.h"
#import "GPMessage.h"

@protocol GPMessageRendererDelegate <NSObject>

- (void)clickedButton:(GPButton *)button message:(GPMessage *)message;
- (void)backgroundTouched:(GPMessage *)message;

@end
//
//  GMSwipeMessageHandler.h
//  GrowthMessage
//
//  Created by 田村 俊太郎 on 2015/07/12.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMMessageHandler.h"
#import "GMSwipeMessageRendererDelegate.h"

@interface GMSwipeMessageHandler : NSObject <GMMessageHandler, GMSwipeMessageRendererDelegate>

@end

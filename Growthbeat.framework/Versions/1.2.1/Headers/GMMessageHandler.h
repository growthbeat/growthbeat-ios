//
//  GMMessageDelegate.h
//  GrowthMessage
//
//  Created by 堀内 暢之 on 2015/03/03.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMMessage.h"
#import "GrowthMessage.h"

@protocol GMMessageHandler <NSObject>

- (BOOL)handleMessage:(GMMessage *)message;

@end
//
//  GMMessageHandler.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPMessage.h"

@protocol GPMessageHandler <NSObject>

- (BOOL)handleMessage:(GPMessage *)message;

@end
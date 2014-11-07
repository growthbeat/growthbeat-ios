//
//  GAService.h
//  GrowthAnalytics
//
//  Created by Kataoka Naoyuki on 2014/11/06.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GrowthbeatCore.h"

@interface GAService : NSObject

- (void)httpRequest:(GBHttpRequest *)httpRequest success:(void(^) (GBHttpResponse * httpResponse)) success fail:(void(^) (GBHttpResponse * httpResponse))fail;

@end

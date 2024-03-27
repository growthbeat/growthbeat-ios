//
//  GPEventHandler.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/20.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growthbeat/GPMessage.h>

@interface GPShowMessageHandler : NSObject {
    void(^ handleMessage)(void(^ messageCallback)());
}

@property (nonatomic, copy)void(^ handleMessage)(void(^ messageCallback)());

- (instancetype)initWithBlock:(void(^)(void(^ messageCallback)()))handleMessage;


@end

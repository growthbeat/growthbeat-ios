//
//  GPEventHandler.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/20.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPMessage.h"

@interface GPEventHandler : NSObject {
    void(^ messageHandler)(GPMessage * message);
}

@property (nonatomic, strong)void(^ messageHandler)(GPMessage *message);

- (instancetype)initWithBlock:(void(^)(GPMessage *message))messageHandler;


@end

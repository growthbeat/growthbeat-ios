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
    void(^ handleMessage)(GPMessage * message);
    void(^ handleFailure)(NSString *detail);
}

@property (nonatomic, strong)void(^ handleMessage)(GPMessage *message);

- (instancetype)initWithBlock:(void(^)(GPMessage *message))handleMessage;


@end

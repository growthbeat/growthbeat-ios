//
//  GBNoopIntentHandler.m
//  GrowthbeatCore
//
//  Created by 堀内 暢之 on 2015/03/08.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GBNoopIntentHandler.h>

@implementation GBNoopIntentHandler

- (BOOL) handleIntent:(GBIntent *)intent {

    if (intent.type != GBIntentTypeNoop) {
        return NO;
    }

    return YES;

}

@end
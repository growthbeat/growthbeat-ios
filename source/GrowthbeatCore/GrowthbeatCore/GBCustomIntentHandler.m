//
//  GBCustomIntentHandler.m
//  GrowthbeatCore
//
//  Created by TABATAKATSUTOSHI on 2015/07/16.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBCustomIntentHandler.h"

@implementation GBCustomIntentHandler
@synthesize block;

- (BOOL) handleIntent:(GBIntent *)intent {
    
    if (intent.type != GBIntentTypeCustom) {
        return NO;
    }
    if (self.block) {
        self.block(intent);
    }
    
    return YES;
    
}


- (void)intentHandlerWithBlock:(void(^)(GBIntent *intent))argBlock{
    self.block = argBlock;
}

@end

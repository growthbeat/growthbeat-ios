//
//  GBCustomIntentHandler.m
//  GrowthbeatCore
//
//  Created by TABATAKATSUTOSHI on 2015/07/16.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBCustomIntentHandler.h"
#import "GrowthbeatCore.h"
#import "GBLogger.h"

@implementation GBCustomIntentHandler
@synthesize block;

- (BOOL) handleIntent:(GBIntent *)intent {
    
    if (intent.type != GBIntentTypeCustom) {
        return NO;
    }
    if (self.block) {
        self.block(intent);
    } else {
        [[[GrowthbeatCore sharedInstance] logger] error:@"error:GBCustomIntentHandler cannot handle intent. cause: block is nil"];
    }
    
    return YES;
    
}


- (void)intentHandlerWithBlock:(void(^)(GBIntent *intent))argBlock{
    self.block = argBlock;
}

@end

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

- (id)initWithBlock:(void(^)(GBIntent *intent))argBlock{
    self = [super init];
    if (self != nil) {
        self.block = argBlock;
    }
    return self;
}

- (BOOL) handleIntent:(GBIntent *)intent {
    
    if (intent.type != GBIntentTypeCustom) {
        return NO;
    }
    if (!self.block) {
        [[[GrowthbeatCore sharedInstance] logger] error:@"GBCustomIntentHandler cannot handle intent. cause: block is nil"];
        return NO;
        
    }
    self.block(intent);
    return YES;
    
}

@end

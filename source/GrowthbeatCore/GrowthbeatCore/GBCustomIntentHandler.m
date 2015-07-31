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

- (id)initWithBlock:(BOOL(^)(GBCustomIntent *customIntent))argBlock{
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
    
    if (![intent isKindOfClass:[GBCustomIntent class]]) {
        return NO;
    }
    
    if (!self.block) {
        [[[GrowthbeatCore sharedInstance] logger] error:@"GBCustomIntentHandler cannot handle intent. cause: block is nil"];
        return NO;
    }
    
    return self.block((GBCustomIntent *)intent);
    
}

@end

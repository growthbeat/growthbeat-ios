//
//  GBCustomIntentHandler.m
//  Growthbeat
//
//  Created by TABATAKATSUTOSHI on 2015/09/09.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GBCustomIntentHandler.h>
#import <Growthbeat/Growthbeat.h>
#import <Growthbeat/GBLogger.h>

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
        [[[Growthbeat sharedInstance] logger] error:@"GBCustomIntentHandler cannot handle intent. cause: block is nil"];
        return NO;
    }
    
    return self.block((GBCustomIntent *)intent);
    
}

@end
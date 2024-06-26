//
//  GPQueue.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GPMessageQueue.h>

@implementation GPMessageQueue

- (id)initWithSize:(int)aMaxSize {
    self = [super init];
    if (self != nil) {
        queue = [[NSMutableArray alloc] init];
        maxSize = aMaxSize;
    }
    return self;
}

- (id)dequeue {
    id headObject;
    @synchronized(queue){
        if ([queue count] == 0) return nil;
        headObject = [queue objectAtIndex:0];
        if (headObject != nil) {
            [queue removeObjectAtIndex:0];
        }
    }
    return headObject;
}

- (void)enqueue:(id)anObject {
    @synchronized(queue){
        if (anObject == nil) {
            return;
        }
        if ([queue count] >= maxSize) {
            [queue removeObjectAtIndex:0];
        }
        [queue addObject:anObject];
    }
}

- (int)count {
    int c = 0;
    @synchronized(queue) {
        c = (int)[queue count];
    }
    return c;
}
@end

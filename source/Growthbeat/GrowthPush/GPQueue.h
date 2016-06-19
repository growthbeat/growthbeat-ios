//
//  GPQueue.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPQueue : NSObject {
    NSMutableArray *queue;
    int maxSize;
}

- (id)initWithSize:(int)maxSize;
- (id)dequeue;
- (void)enqueue:(id)anObject ;
- (int)count;

@end

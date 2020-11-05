//
//  GPSwipeMessage.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPMessage.h"
#import "GPSwipeMessageType.h"

@interface GPSwipeMessage : GPMessage {
    
    GPSwipeMessageType swipeType;
    NSArray *pictures;
    NSInteger baseWidth;
    NSInteger baseHeight;
    
}

@property (nonatomic, assign) GPSwipeMessageType swipeType;
@property (nonatomic, strong) NSArray *pictures;
@property (nonatomic, assign) NSInteger baseWidth;
@property (nonatomic, assign) NSInteger baseHeight;


@end

//
//  GMButton.h
//  GrowthMessage
//
//  Created by 堀内 暢之 on 2015/03/03.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"
#import "GBIntent.h"
#import "GMButtonType.h"

@class GMMessage;

@interface GMButton : GBDomain <NSCoding> {

    GMButtonType type;
    NSDate *created;
    GMMessage *message;
    GBIntent *intent;

}

@property (nonatomic, assign) GMButtonType type;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) GMMessage *message;
@property (nonatomic, strong) GBIntent *intent;

@end

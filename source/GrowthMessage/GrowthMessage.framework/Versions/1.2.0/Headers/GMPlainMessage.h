//
//  GMPlainMessage.h
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/03/17.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMMessage.h"

@interface GMPlainMessage : GMMessage {

    NSString *caption;
    NSString *text;

}

@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *text;

@end

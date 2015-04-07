//
//  GMImageMessage.h
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/03/17.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMMessage.h"

@interface GMImageMessage : GMMessage {

    NSString *url;

}

@property (nonatomic, strong) NSString *url;

@end

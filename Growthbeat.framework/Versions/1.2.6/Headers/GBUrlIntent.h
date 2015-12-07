//
//  GBUrlIntent.h
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2015/03/17.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBIntent.h"

@interface GBUrlIntent : GBIntent <NSCoding> {

    NSString *url;

}

@property (nonatomic, strong) NSString *url;

@end

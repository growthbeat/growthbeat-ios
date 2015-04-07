//
//  GBCustomIntent.h
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2015/03/17.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBIntent.h"

@interface GBCustomIntent : GBIntent <NSCoding> {

    NSDictionary *extra;

}

@property (nonatomic, strong) NSDictionary *extra;

@end

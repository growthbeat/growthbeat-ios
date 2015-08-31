//
//  GBApplication.h
//  GrowthbeatCore
//
//  Created by Kataoka Naoyuki on 2014/06/18.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"

@interface GBApplication : GBDomain <NSCoding> {

    NSString *id;
    NSString *name;
    NSDate *created;

}

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *created;

@end

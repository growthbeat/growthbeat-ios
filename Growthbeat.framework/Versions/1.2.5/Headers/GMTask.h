//
//  GMTask.h
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/03/15.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"

@interface GMTask : GBDomain <NSCoding> {

    NSString *id;
    NSString *applicationId;
    NSString *name;
    NSString *description;
    NSDate *availableFrom;
    NSDate *availableTo;
    BOOL disabled;
    NSDate *created;
    NSDate *updated;

}

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSDate *availableFrom;
@property (nonatomic, strong) NSDate *availableTo;
@property (nonatomic, assign) BOOL disabled;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *updated;


@end

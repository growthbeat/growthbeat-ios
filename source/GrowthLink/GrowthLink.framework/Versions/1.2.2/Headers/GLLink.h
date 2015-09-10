//
//  GLLink.h
//  Growthbeat
//
//  Created by Naoyuki Kataoka on 2015/06/08.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GBDomain.h>

@interface GLLink : GBDomain <NSCoding> {

    NSString *id;
    NSString *alias;
    NSString *applicationId;
    NSString *name;

}

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *alias;
@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, strong) NSString *name;

@end

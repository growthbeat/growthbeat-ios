//
//  GLPattern.h
//  Growthbeat
//
//  Created by Naoyuki Kataoka on 2015/06/08.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GBDomain.h>
#import "GLLink.h"
#import <Growthbeat/GBIntent.h>

@interface GLPattern : GBDomain <NSCoding> {

    NSString *id;
    NSString *url;
    GLLink *link;
    GBIntent *intent;
    NSDate *created;
    NSDate *updated;

}

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) GLLink *link;
@property (nonatomic, strong) GBIntent *intent;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *updated;

@end

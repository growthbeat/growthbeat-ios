//
//  GLClick.h
//  Growthbeat
//
//  Created by Naoyuki Kataoka on 2015/06/08.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GBDomain.h>
#import "GLPattern.h"

@interface GLClick : GBDomain <NSCoding> {

    NSString *id;
    GLPattern *pattern;
    NSString *clientId;
    BOOL open;
    BOOL install;
    NSDate *created;
    NSDate *accessed;

}

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) GLPattern *pattern;
@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, assign) BOOL open;
@property (nonatomic, assign) BOOL install;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *accessed;

+ (instancetype)deeplinkWithClientId:(NSString *)clientId clickId:(NSString *)clickId install:(BOOL)install credentialId:(NSString *)credentialId;

@end

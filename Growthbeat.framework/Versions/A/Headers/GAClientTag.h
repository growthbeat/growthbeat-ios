//
//  GAClientTag.h
//  GrowthAnalytics
//
//  Created by Kataoka Naoyuki on 2014/11/06.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import "GADomain.h"

@interface GAClientTag : GADomain {
    
    NSString *id;
    NSString *clientId;
    NSString *tagId;
    NSString *value;
    NSDate *created;
    
}

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *tagId;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSDate *created;

@end

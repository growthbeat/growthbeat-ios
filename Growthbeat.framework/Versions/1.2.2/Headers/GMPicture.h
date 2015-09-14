//
//  GMPicture.h
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/04/20.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"
#import "GMPictureExtension.h"

@interface GMPicture : GBDomain <NSCoding> {

    NSString *id;
    NSString *applicationId;
    GMPictureExtension extension;
    NSInteger width;
    NSInteger height;
    NSString *name;
    NSDate *created;
    NSDate *updated;
    NSString *url;

}

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, assign) GMPictureExtension extension;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *updated;
@property (nonatomic, strong) NSString *url;

@end

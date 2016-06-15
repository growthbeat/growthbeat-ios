//
//  GPPicture.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"
#import "GPPictureExtension.h"

@interface GPPicture  : GBDomain <NSCoding> {
    
    NSString *id;
    NSString *applicationId;
    GPPictureExtension extension;
    NSInteger width;
    NSInteger height;
    NSString *name;
    NSDate *created;
    NSDate *updated;
    NSString *url;
    
}

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, assign) GPPictureExtension extension;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *updated;
@property (nonatomic, strong) NSString *url;

@end

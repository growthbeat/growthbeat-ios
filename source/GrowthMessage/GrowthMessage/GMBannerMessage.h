//
//  GMBannerMessage.h
//  GrowthMessage
//
//  Created by Baekwoo Chung on 2015/06/02.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMMessage.h"
#import "GMPicture.h"
#import "GMBannerType.h"

@interface GMBannerMessage : GMMessage {
    
    GMPicture *picture;
    NSString *caption;
    NSString *text;
    GMBannerType bannerType;
    GMBannerType position;
    NSInteger duration;
    
}

@property (nonatomic, strong) GMPicture *picture;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) GMBannerType bannerType;
@property (nonatomic, assign) GMBannerType position;
@property (nonatomic, assign) NSInteger duration;

@end

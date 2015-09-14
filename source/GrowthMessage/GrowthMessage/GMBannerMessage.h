//
//  GMBannerMessage.h
//  GrowthMessage
//
//  Created by Baekwoo Chung on 2015/06/02.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMMessage.h"
#import "GMPicture.h"
#import "GMBannerMessageType.h"
#import "GMBannerMessagePosition.h"

@interface GMBannerMessage : GMMessage {

    GMPicture *picture;
    NSString *caption;
    NSString *text;
    GMBannerMessageType bannerType;
    GMBannerMessagePosition position;
    long long duration;

}

@property (nonatomic, strong) GMPicture *picture;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) GMBannerMessageType bannerType;
@property (nonatomic, assign) GMBannerMessagePosition position;
@property (nonatomic, assign) long long duration;

@end

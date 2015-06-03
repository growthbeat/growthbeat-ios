//
//  GMBannerMessage.h
//  GrowthMessage
//
//  Created by Baekwoo Chung on 2015/06/02.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMMessage.h"
#import "GMPicture.h"

@interface GMBannerMessage : GMMessage {
    
    GMPicture *picture;
    
}

@property (nonatomic, strong) GMPicture *picture;

@end

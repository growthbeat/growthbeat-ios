//
//  GMSwipeMessage.h
//  GrowthMessage
//
//  Created by 田村 俊太郎 on 2015/07/12.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMMessage.h"
#import "GMSwipeMessageType.h"
#import "GMSwipeImages.h"

@interface GMSwipeMessage : GMMessage {

    GMSwipeMessageType swipeType;
    GMSwipeImages *swipeImages;

}

@property (nonatomic, assign) GMSwipeMessageType swipeType;
@property (nonatomic, strong) GMSwipeImages *swipeImages;

@end

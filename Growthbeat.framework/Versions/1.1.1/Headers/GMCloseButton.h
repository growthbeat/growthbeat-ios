//
//  GMCloseButton.h
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/04/20.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMButton.h"
#import "GMPicture.h"

@interface GMCloseButton : GMButton {

    GMPicture *picture;

}

@property (nonatomic, strong) GMPicture *picture;

@end

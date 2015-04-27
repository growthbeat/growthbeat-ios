//
//  GMImageButton.h
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/03/17.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMButton.h"
#import "GMPicture.h"

@interface GMImageButton : GMButton {

    GMPicture *picture;

}

@property (nonatomic, strong) GMPicture *picture;

@end

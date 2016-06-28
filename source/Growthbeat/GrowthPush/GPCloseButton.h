//
//  GPCloseButton.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPButton.h"
#import "GPPicture.h"
#import "GPPictureOwner.h"

@interface GPCloseButton : GPButton<GPPictureOwner> {
    
    GPPicture *picture;
    NSInteger baseWidth;
    NSInteger baseHeight;
    
}

@property (nonatomic, strong) GPPicture *picture;
@property (nonatomic, assign) NSInteger baseWidth;
@property (nonatomic, assign) NSInteger baseHeight;

@end

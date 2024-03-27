//
//  GPImageButton.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GPButton.h>
#import <Growthbeat/GPPicture.h>

@interface GPImageButton : GPButton {
    
    GPPicture *picture;
    NSInteger baseWidth;
    NSInteger baseHeight;
    
}

@property (nonatomic, strong) GPPicture *picture;
@property (nonatomic, assign) NSInteger baseWidth;
@property (nonatomic, assign) NSInteger baseHeight;


@end

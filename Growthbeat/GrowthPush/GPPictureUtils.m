//
//  GPPictureUtils.m
//  GrowthbeatSample
//
//  Created by 内山陽介 on 2016/06/28.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPPictureUtils.h"

@implementation GPPictureUtils

+ (CGSize) calculatePictureSize:(GPPicture *)picture baseWidth:(NSInteger)baseWidth baseHeight:(NSInteger)baseHeight {
    float scale = 1.0f;
    float widthScale = baseWidth / picture.width;
    float heightScale = baseHeight / picture.height;
    if (widthScale < 1.0f || heightScale < 1.0f) {
        scale = MIN(widthScale, heightScale);
    }
    
    float width = ceilf(picture.width * scale);
    float height = ceilf(picture.height * scale);
    return CGSizeMake(width, height);
}

@end

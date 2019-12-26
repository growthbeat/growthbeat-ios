//
//  GPPictureUtils.h
//  GrowthbeatSample
//
//  Created by 内山陽介 on 2016/06/28.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GPPicture.h"

@interface GPPictureUtils : NSObject

+ (CGSize) calculatePictureSize:(GPPicture *)picture baseWidth:(NSInteger)baseWidth baseHeight:(NSInteger)baseHeight;

@end

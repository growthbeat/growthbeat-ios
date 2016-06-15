//
//  GPSwipeImages.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"

@interface GPSwipeImages : GBDomain <NSCoding> {
    
    NSArray *pictures;
    float widthRatio;
    float topMargin;
    
}

@property (nonatomic, strong) NSArray *pictures;
@property (nonatomic, assign) float widthRatio;
@property (nonatomic, assign) float topMargin;

@end

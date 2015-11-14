//
//  GMSwipeImages.h
//  Growthbeat
//
//  Created by 尾川 茂 on 2015/08/18.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"

@interface GMSwipeImages : GBDomain <NSCoding> {

    NSArray *pictures;
    float widthRatio;
    float topMargin;

}

@property (nonatomic, strong) NSArray *pictures;
@property (nonatomic, assign) float widthRatio;
@property (nonatomic, assign) float topMargin;

@end

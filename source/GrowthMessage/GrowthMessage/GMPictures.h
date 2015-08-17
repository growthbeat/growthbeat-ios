//
//  GMPictures.h
//  GrowthMessage
//
//  Created by 田村 俊太郎 on 2015/08/18.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"

@interface GMPictures : GBDomain <NSCoding> {
    
    NSArray *ids;
    float widthRatio;
    float topMargin;
    
}

@property (nonatomic, strong) NSArray *ids;
@property (nonatomic, assign) float widthRatio;
@property (nonatomic, assign) float topMargin;

@end

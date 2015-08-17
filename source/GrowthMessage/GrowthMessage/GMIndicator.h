//
//  GMIndicator.h
//  GrowthMessage
//
//  Created by 田村 俊太郎 on 2015/08/18.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//


#import "GBDomain.h"

@interface GMIndicator : GBDomain <NSCoding> {
    
    float topMargin;
    
}

@property (nonatomic, assign) float topMargin;

@end

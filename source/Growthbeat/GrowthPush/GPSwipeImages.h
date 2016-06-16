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
    
}

@property (nonatomic, strong) NSArray *pictures;

@end

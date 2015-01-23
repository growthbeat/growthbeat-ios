//
//  GRConfiguration.h
//  replay
//
//  Created by A13048 on 2014/01/28.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GBDomain.h"

@interface GRConfiguration : GBDomain<NSCoding> {

    float recordTerm;
    NSInteger compressibility;
    float scale;
    NSInteger numberOfRemaining;
    NSArray *wheres;

}

@property (nonatomic) float recordTerm;
@property (nonatomic) NSInteger compressibility;
@property (nonatomic) float scale;
@property (nonatomic) NSInteger numberOfRemaining;
@property (nonatomic) NSArray *wheres;

- (NSString*) getJSONString;

@end

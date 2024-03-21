//
//  GPPlainButton.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GPButton.h>

@interface GPPlainButton : GPButton <NSCoding> {
    
    NSString *label;
    
}

@property (nonatomic, strong) NSString *label;

@end

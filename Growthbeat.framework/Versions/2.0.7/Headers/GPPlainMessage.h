//
//  GPPlainMessage.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPMessage.h"

@interface GPPlainMessage : GPMessage {
    
    NSString *caption;
    NSString *text;
    
}

@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *text;

@end

//
//  GPButton.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <Growthbeat/GBDomain.h>
#import <Growthbeat/GBIntent.h>
#import <Growthbeat/GPButtonType.h>

@class GPMessage;

@interface GPButton : GBDomain <NSCoding> {
    
    GPButtonType type;
    NSDate *created;
    GPMessage *message;
    GBIntent *intent;
    
}

@property (nonatomic, assign) GPButtonType type;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) GPMessage *message;
@property (nonatomic, strong) GBIntent *intent;

@end

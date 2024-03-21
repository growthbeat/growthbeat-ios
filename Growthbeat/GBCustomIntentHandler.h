//
//  GBCustomIntentHandler.h
//  Growthbeat
//
//  Created by TABATAKATSUTOSHI on 2015/09/09.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Growthbeat/GBIntentHandler.h>
#import <Growthbeat/GBIntent.h>
#import <Growthbeat/GBCustomIntent.h>

@interface GBCustomIntentHandler : NSObject <GBIntentHandler> {
    
    BOOL(^block)(GBCustomIntent *customIntent);
    
}

@property (copy, nonatomic) BOOL(^block)(GBCustomIntent *customIntent);

- (id)initWithBlock:(BOOL(^)(GBCustomIntent *customIntent))argBlock;

@end
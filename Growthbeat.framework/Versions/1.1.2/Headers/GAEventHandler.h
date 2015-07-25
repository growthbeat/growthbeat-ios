//
//  GAEventHandler.h
//  GrowthAnalytics
//
//  Created by Naoyuki Kataoka on 2015/03/13.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GAEventHandler : NSObject {

    void(^ callback)(NSString * eventId, NSDictionary * properties);

}

@property (nonatomic, strong)void(^ callback)(NSString * eventId, NSDictionary * properties);

- (instancetype)initWithCallback:(void(^)(NSString * eventId, NSDictionary * properties))callback;

@end

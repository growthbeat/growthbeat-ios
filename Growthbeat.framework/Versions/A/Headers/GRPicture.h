//
//  GRPicture.h
//  replay
//
//  Created by A13048 on 2014/01/30.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GRDomain.h"

@interface GRPicture : GRDomain<NSCoding> {

    BOOL continuation;
    BOOL status;
    BOOL recordedClient;
}

@property (nonatomic) BOOL continuation;
@property (nonatomic) BOOL status;
@property (nonatomic) BOOL recordedClient;

@end

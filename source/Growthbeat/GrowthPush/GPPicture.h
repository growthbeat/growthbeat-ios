//
//  GPPicture.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GBDomain.h"

@interface GPPicture  : GBDomain <NSCoding> {
    
    NSString *id;
    NSString *applicationId;
    NSDate *created;
    NSString *url;
    
}

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSString *url;

@end

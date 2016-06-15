//
//  GPImageMessage.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPMessage.h"
#import "GPPicture.h"

@interface GPImageMessage : GPMessage {
    
    GPPicture *picture;
    
}

@property (nonatomic, strong) GPPicture *picture;

@end

//
//  GBMultipartFile.h
//  replay
//
//  Created by Kataoka Naoyuki on 2014/02/05.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBMultipartFile : NSObject {

    NSString *fileName;
    NSString *contentType;
    NSData *body;

}

@property (nonatomic) NSString *fileName;
@property (nonatomic) NSString *contentType;
@property (nonatomic) NSData *body;

+ (id)multipartFileWithFileName:(NSString *)fileName contentType:(NSString *)contentType body:(NSData *)body;

@end

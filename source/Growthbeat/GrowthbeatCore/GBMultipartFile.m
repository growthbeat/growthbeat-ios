//
//  GBMultipartFile.m
//  replay
//
//  Created by Kataoka Naoyuki on 2014/02/05.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GBMultipartFile.h"

@implementation GBMultipartFile

@synthesize fileName;
@synthesize contentType;
@synthesize body;

+ (id) multipartFileWithFileName:(NSString *)fileName contentType:(NSString *)contentType body:(NSData *)body {

    GBMultipartFile *multipartFile = [[self alloc] init];

    multipartFile.fileName = fileName;
    multipartFile.contentType = contentType;
    multipartFile.body = body;

    return multipartFile;

}

@end

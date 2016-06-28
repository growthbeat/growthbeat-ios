//
//  GPCloseButton.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPCloseButton.h"

@implementation GPCloseButton

@synthesize picture;
@synthesize baseWidth;
@synthesize baseHeight;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary objectForKey:@"picture"] && [dictionary objectForKey:@"picture"] != [NSNull null]) {
            self.picture = [GPPicture domainWithDictionary:[dictionary objectForKey:@"picture"]];
        }
        if ([dictionary objectForKey:@"baseWidth"] && [dictionary objectForKey:@"baseWidth"] != [NSNull null]) {
            self.baseWidth = [[dictionary objectForKey:@"baseWidth"] integerValue];
        }
        if ([dictionary objectForKey:@"baseHeight"] && [dictionary objectForKey:@"baseHeight"] != [NSNull null]) {
            self.baseHeight = [[dictionary objectForKey:@"baseHeight"] integerValue];
        }
    }
    return self;
    
}

#pragma mark --
#pragma mark NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([aDecoder containsValueForKey:@"picture"]) {
            self.picture = [aDecoder decodeObjectForKey:@"picture"];
        }
        if ([aDecoder containsValueForKey:@"baseWidth"]) {
            self.baseWidth = [aDecoder decodeIntegerForKey:@"baseWidth"];
        }
        if ([aDecoder containsValueForKey:@"baseHeight"]) {
            self.baseHeight = [aDecoder decodeIntegerForKey:@"baseHeight"];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:picture forKey:@"picture"];
    [aCoder encodeInteger:baseWidth forKey:@"baseWidth"];
    [aCoder encodeInteger:baseHeight forKey:@"baseHeight"];
}

# pragma mark --
# pragma mark GPPictureOwner

- (CGSize) pictureSize {
    float scale = 1.0f;
    float widthScale = self.baseWidth / self.picture.width;
    float heightScale = self.baseHeight / self.picture.height;
    if (widthScale < 1.0f || heightScale < 1.0f) {
        scale = MIN(widthScale, heightScale);
    }
    
    float width = ceilf(self.picture.width * scale);
    float height = ceilf(self.picture.height * scale);
    return CGSizeMake(width, height);
}

@end

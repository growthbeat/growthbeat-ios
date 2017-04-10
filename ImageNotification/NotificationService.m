//
//  NotificationService.m
//  ImageNotification
//
//  Created by Shigeru Ogawa on 2017/04/10.
//  Copyright © 2017年 SIROK, Inc. All rights reserved.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    NSString* imageUrl = [request.content.userInfo objectForKey:@"image"];
    if(imageUrl) {
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSURLSessionTask *task = [session dataTaskWithURL:[NSURL URLWithString:imageUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSURL *writePath = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"tmp.png"];
            [data writeToURL:writePath atomically:YES];
            UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"GrowthbeatSample" URL:writePath options:nil error:nil];
            UNMutableNotificationContent *content = [request.content mutableCopy];
            content.attachments = @[attachment];
            
            self.contentHandler(content);
            
        }];
        [task resume];
    } else {
        self.contentHandler(self.bestAttemptContent);
    }
    
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end

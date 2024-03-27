//
//  Growthbeat.h
//  Growthbeat
//
//  Created by Kataoka Naoyuki on 2014/06/13.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growthbeat/GBAppDelegateWrapper.h>
#import <Growthbeat/GBAppDelegateWrapperDelegate.h>
#import <Growthbeat/GBApplication.h>
#import <Growthbeat/GBClient.h>
#import <Growthbeat/GBContentType.h>
#import <Growthbeat/GBCustomIntent.h>
#import <Growthbeat/GBCustomIntentHandler.h>
#import <Growthbeat/GBDateUtils.h>
#import <Growthbeat/GBDeviceUtils.h>
#import <Growthbeat/GBDomain.h>
#import <Growthbeat/GBGPClient.h>
#import <Growthbeat/GBHttpClient.h>
#import <Growthbeat/GBHttpRequest.h>
#import <Growthbeat/GBHttpResponse.h>
#import <Growthbeat/GBHttpUtils.h>
#import <Growthbeat/GBIntent.h>
#import <Growthbeat/GBIntentHandler.h>
#import <Growthbeat/GBIntentType.h>
#import <Growthbeat/GBLogger.h>
#import <Growthbeat/GBNoopIntent.h>
#import <Growthbeat/GBNoopIntentHandler.h>
#import <Growthbeat/GBPreference.h>
#import <Growthbeat/GBRequestMethod.h>
#import <Growthbeat/GBUrlIntent.h>
#import <Growthbeat/GBUrlIntentHandler.h>
#import <Growthbeat/GBUtils.h>
#import <Growthbeat/GBViewUtils.h>
#import <Growthbeat/GrowthPush.h>
#import <Growthbeat/GPBackground.h>
#import <Growthbeat/GPButton.h>
#import <Growthbeat/GPButtonType.h>
#import <Growthbeat/GPCardMessage.h>
#import <Growthbeat/GPCardMessageHandler.h>
#import <Growthbeat/GPCardMessageRenderer.h>
#import <Growthbeat/GPClient.h>
#import <Growthbeat/GPClientV4.h>
#import <Growthbeat/GPCloseButton.h>
#import <Growthbeat/GPEnvironment.h>
#import <Growthbeat/GPEvent.h>
#import <Growthbeat/GPEventType.h>
#import <Growthbeat/GPImageButton.h>
#import <Growthbeat/GPMessage.h>
#import <Growthbeat/GPMessageHandler.h>
#import <Growthbeat/GPMessageOrientation.h>
#import <Growthbeat/GPMessageQueue.h>
#import <Growthbeat/GPMessageRendererDelegate.h>
#import <Growthbeat/GPMessageType.h>
#import <Growthbeat/GPNoContentMessage.h>
#import <Growthbeat/GPOS.h>
#import <Growthbeat/GPPicture.h>
#import <Growthbeat/GPPictureUtils.h>
#import <Growthbeat/GPPlainButton.h>
#import <Growthbeat/GPPlainMessage.h>
#import <Growthbeat/GPPlainMessageHandler.h>
#import <Growthbeat/GPScreenButton.h>
#import <Growthbeat/GPShowMessageCount.h>
#import <Growthbeat/GPShowMessageHandler.h>
#import <Growthbeat/GPSwipeMessage.h>
#import <Growthbeat/GPSwipeMessageHandler.h>
#import <Growthbeat/GPSwipeMessageRenderer.h>
#import <Growthbeat/GPSwipeMessageType.h>
#import <Growthbeat/GPTag.h>
#import <Growthbeat/GPTagType.h>
#import <Growthbeat/GPTask.h>

@interface Growthbeat : NSObject {

    NSMutableArray *intentHandlers;

}

@property (nonatomic, strong) NSArray *intentHandlers;

+ (Growthbeat *)sharedInstance;

- (void)initializeWithApplicationId:(NSString *)applicationId credentialId:(NSString *)credentialId;

- (GBLogger *)logger;
- (GBHttpClient *)httpClient;
- (GBPreference *)preference;

- (GBClient *)client;
- (GBClient *)waitClient;

- (void)setLoggerSilent:(BOOL) silent;
- (BOOL)handleIntent:(GBIntent *)intent;
- (void)addIntentHandler:(NSObject *)intentHandler;
- (void)addCustomIntentHandlerWithBlock:(BOOL(^)(GBCustomIntent *customIntent))block;


@end

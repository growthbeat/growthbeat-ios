# Growthbeat SDK for iOS

[Growthbeat](https://growthbeat.com/) is growth hack platform for smart devices.

## Usage

### Growthbeat

1. Add Growthbeat.framework into your project. 

1. Link SystemConfiguration.framework and AdSupport.framework. 

1. Import the framework header.

	```objc
	#import <Growthbeat/Growthbeat.h>
	```

1. Write initialization code

	```objc
	[[Growthbeat sharedInstance] initializeWithApplicationId:@"APPLICATION_ID" credentialId:@"CREDENTIAL_ID"];
	```
	
1. Call Growthbeat's start method on applicationDidBecomeActive:

	```objc
	[[Growthbeat sharedInstance] start];
	```
	
1. Call Growthbeat's stop method on applicationWillResignActive:

	```objc
	[[Growthbeat sharedInstance] stop];
	```

### Growth Analytics

1. Write following code in the place to track custom event with Growth Analytics.

	```objc
	[[GrowthAnalytics sharedInstance] track:@"EVENT_NAME"];
	```

### Growth Message

1. Write following code in the place to display a message with Growth Message. (The same code with Growth Analytics)

	```objc
	[[GrowthAnalytics sharedInstance] track:@"EVENT_NAME"];
	```

### Growth Push

1. Call requestDeviceToken to get apns device token and send it to server.

	```objc
	[[GrowthPush sharedInstance] requestDeviceTokenWithEnvironment:kGrowthPushEnvironment];
	```

1. Write following code to handle url in UIApplicationDelegate's application:didRegisterForRemoteNotificationsWithDeviceToken:. 

	```objc
	[[GrowthPush sharedInstance] setDeviceToken:deviceToken];
	```

### Growth Link

1. Add GrowthLink.framework into your project. 

1. Write initialization code.

	```objc
	[[GrowthLink sharedInstance] initializeWithApplicationId:@"APPLICATION_ID" credentialId:@"CREDENTIAL_ID"];
	```

1. Write following code to handle url in UIApplicationDelegate's application:openURL:sourceApplication:annotation:. 

	```objc
	[[GrowthLink sharedInstance] handleOpenUrl:url];
	```

## Included SDKs

Growthbeat is growth hack platform for mobile apps. This repository includes Growthbeat Core SDK, Growth Push SDK and Growth Replay SDK.

* Growthbeat Core - core functions for Growthbeat integrated services.
* Growth Analytics - analytics service for mobile apps.
* Growth Message - in-app message tool for mobile apps.
* Growth Push - push notification and analysis platform for mobile apps.
* Growth Link (Pre-release) - deep linking tool.
* Growth Replay (Under development) - usability testing tool for mobile apps.

# Building framework

1. Set build target to GrowthbeatFramework and iOS Device.
1. Run.

Archive the project on Xcode and you will get framework package.

## License

Apache License, Version 2.0

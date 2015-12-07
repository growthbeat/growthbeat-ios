Growthbeat SDK for iOS

===
[![License](https://img.shields.io/badge/license-Apache%202-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)
[![Download](https://img.shields.io/cocoapods/v/Growthbeat.svg)](https://cocoapods.org/?q=growthbeat)

[Growthbeat](https://growthbeat.com/) is growth hack platform for smart devices.

## Install

- **CocoaPods**

Add Podfile.

```
pod 'Growthbeat'
```

Run command.

```sh
pod install
```

## Dependencies

- Foundation.framework
- UIKit.framework
- CoreGraphics.framework
- SystemConfiguration.framework
- AdSupport.framework
- CFNetwork.framework

## Usage

### Growthbeat

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
	- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
		[[GrowthPush sharedInstance] setDeviceToken:deviceToken];
	}
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

## Supported Environment

* iOS5 and later.

## License

Apache License, Version 2.0

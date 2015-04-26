# Growthbeat SDK for iOS

Growthbeat SDK for iOS

## Usage

1. Add Growthbeat.framework into your project. 

1. Link SystemConfiguration.framework and AdSupport.framework. 

1. Import the framework header.

	```objc
	#import <Growthbeat/Growthbeat.h>
	```

1. Write initialization code

	```objc
	[[Growthbeat sharedInstance] initializeWithApplicationId:@"APPLICATION_ID" credentialId:@"CREDENTIAL_ID"];
	[[Growthbeat sharedInstance] initializeGrowthAnalytics];
	[[Growthbeat sharedInstance] initializeGrowthMessage];
	```
	
1. Call Growthbeat's start method on applicationDidBecomeActive:

	```objc
	[[Growthbeat sharedInstance] start];
	```
	
1. Call Growthbeat's stop method on applicationWillResignActive:

	```objc
	[[Growthbeat sharedInstance] stop];
	```

1. Write following code in the place to track custom event with Growth Analytics or display a message with Growth Message.

	```objc
    [[GrowthAnalytics sharedInstance] track:@"EVENT_ID"];
	```

## Included SDKs

Growthbeat is growth hack platform for mobile apps. This repository includes Growthbeat Core SDK, Growth Push SDK and Growth Replay SDK.

### Growthbeat Core

Growthbeat Core SDK is core functions for Growthbeat integrated services.

* [Growthbeat Core SDK for iOS](https://github.com/SIROK/growthbeat-core-ios/)

### Growth Analytics

[Growth Analytics](https://analytics.growthbeat.com/) is analytics service for mobile apps.

* [Growth Analytics SDK for iOS](https://github.com/SIROK/growthanalytics-ios)

### Growth Message

[Growth Message](https://message.growthbeat.com/) is in-app message tool for mobile apps.

* [Growth Message SDK for iOS](https://github.com/SIROK/growthmessage-ios)

### Growth Push (Under development)

[Growth Push](https://growthpush.com/) is push notification and analysis platform for mobile apps.

* [Growth Push SDK for iOS](https://github.com/SIROK/growthpush-ios)

### Growth Replay (Under development)

[Growth Replay](https://growthreplay.com/) is usability testing tool for mobile apps.

* [Growth Replay SDK for iOS](https://github.com/SIROK/growthreplay-ios)

# Building framework

1. Set build target to GrowthAnalyticsFramework and iOS Device.
1. Run.

Archive the project on Xcode and you will get framework package.

## License

Apache License, Version 2.0

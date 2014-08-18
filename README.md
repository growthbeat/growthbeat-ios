# Growthbeat SDK for iOS

Growthbeat SDK for iOS

## Usage

1. Add Growthbeat.framework into your project. 

1. Import the framework header.

	```objc
	#import <Growthbeat/Growthbeat.h>
	```

1. Write initialization code

	```objc
	[[Growthbeat sharedInstance] initializeWithApplicationId:@"APPLICATION_ID" credentialId:@"CREDENTIAL_ID"];
	```

	You can get the APPLICATION_ID and CREDENTIAL_ID on web site of Growthbeat. 

1. Use Growth Push.

	```objc
	[[Growthbeat sharedInstance] initializeGrowthPushWithEnvironment:kGrowthPushEnvironment];
	```

1. Use Growth Replay.

	```objc
	[[Growthbeat sharedInstance] initializeGrowthReplay];
	[GrowthReplay start];
	```

1. Track events and set tags.

	```objc
	[GrowthPush setTag:@"NAME" value:@"VALUE"];
	[GrowthPush trackEvent:@"NAME" value:@"VALUE"];
	```

## Included SDKs

Growthbeat is growth hack platform for mobile apps. This repository includes Growthbeat Core SDK, Growth Push SDK and Growth Replay SDK.

### Growthbeat Core

Growthbeat Core SDK is core functions for Growthbeat integrated services.

* [Growthbeat Core SDK for iOS](https://github.com/SIROK/growthbeat-core-ios/)

### Growth Push

[Growth Push](https://growthpush.com/) is push notification and analysis platform for mobile apps.

* [Growth Push SDK for iOS](https://github.com/SIROK/growthpush-ios)

### Growth Replay

[Growth Replay](https://growthreplay.com/) is usability testing tool for mobile apps.

* [Growth Replay SDK for iOS](https://github.com/SIROK/growthreplay-ios)

# Building framework

[iOS-Universal-Framework](https://github.com/kstenerud/iOS-Universal-Framework) is required.

```bash
git clone https://github.com/kstenerud/iOS-Universal-Framework.git
cd ./iOS-Universal-Framework/Real\ Framework/
./install.sh
```

Archive the project on Xcode and you will get framework package.

## License

Apache License, Version 2.0

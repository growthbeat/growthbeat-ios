//
//  ViewController.m
//  GrowthbeatSample
//
//  Created by Kataoka Naoyuki on 2014/08/10.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import "ViewController.h"
#import <Growthbeat/Growthbeat.h>

@implementation ViewController

@synthesize developmentTagSwitch;
@synthesize levelTextField;
@synthesize itemTextField;
@synthesize priceTextField;

- (IBAction) tapRandomTagButton:(id)sender {
    //[[GrowthAnalytics sharedInstance] setRandom];
}

- (IBAction) changeDevelopmentTagSwitch:(id)sender {
    //[[GrowthAnalytics sharedInstance] setDevelopment:developmentTagSwitch.on];
}

- (IBAction) tapLevelTagButton:(id)sender {
    //[[GrowthAnalytics sharedInstance] setLevel:[levelTextField.text intValue]];
}

- (IBAction) tapPurchaseEventButton:(id)sender {
    //[[GrowthAnalytics sharedInstance] purchase:[priceTextField.text intValue] setCategory:@"item" setProduct:itemTextField.text];
}

@end

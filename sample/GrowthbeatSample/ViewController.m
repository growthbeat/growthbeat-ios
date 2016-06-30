//
//  ViewController.m
//  GrowthbeatSample
//
//  Created by Kataoka Naoyuki on 2014/08/10.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import "ViewController.h"
#import <Growthbeat/Growthbeat.h>
#import <Growthbeat/GrowthPush.h>

@implementation ViewController

@synthesize tagNameTextField;
@synthesize tagValueTextField;
@synthesize eventNameTextField;
@synthesize eventValueTextField;

- (IBAction)tapSetTagButton:(id)sender {
    [[GrowthPush sharedInstance] setTag:tagNameTextField.text value:tagValueTextField.text];
}

- (IBAction)tapTrackEvent:(id)sender {
    [[GrowthPush sharedInstance] trackEvent:eventNameTextField.text value:eventValueTextField.text];
}

- (IBAction)didEndOnExit:(id)sender {
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
}

@end

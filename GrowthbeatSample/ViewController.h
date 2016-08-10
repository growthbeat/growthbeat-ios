//
//  ViewController.h
//  GrowthbeatSample
//
//  Created by Kataoka Naoyuki on 2014/08/10.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {

}

@property (weak, nonatomic) IBOutlet UITextField *tagNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *tagValueTextField;
@property (weak, nonatomic) IBOutlet UITextField *eventNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *eventValueTextField;

- (IBAction)tapSetTagButton:(id)sender;
- (IBAction)tapTrackEvent:(id)sender;
- (IBAction)didEndOnExit:(id)sender;
- (IBAction)onTap:(id)sender;

@end

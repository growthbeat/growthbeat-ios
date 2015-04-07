//
//  ViewController.h
//  GrowthbeatSample
//
//  Created by Kataoka Naoyuki on 2014/08/10.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    
    IBOutlet UISwitch *developmentTagSwitch;
    IBOutlet UITextField *levelTextField;
    IBOutlet UITextField *itemTextField;
    IBOutlet UITextField *priceTextField;
    
}

@property (nonatomic, strong) IBOutlet UISwitch *developmentTagSwitch;
@property (nonatomic, strong) IBOutlet UITextField *levelTextField;
@property (nonatomic, strong) IBOutlet UITextField *itemTextField;
@property (nonatomic, strong) IBOutlet UITextField *priceTextField;

- (IBAction)tapRandomTagButton:(id)sender;
- (IBAction)changeDevelopmentTagSwitch:(id)sender;
- (IBAction)tapLevelTagButton:(id)sender;
- (IBAction)tapPurchaseEventButton:(id)sender;

@end

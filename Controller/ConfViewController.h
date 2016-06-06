//
//  ConfViewController.h
//  CloudSample
//
//  Created by Young on 15/6/24.
//  Copyright (c) 2015年 young. All rights reserved.
//

#import <UIKit/UIKit.h>

extern int iOnlyConf;
@interface ConfViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *confTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *confPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confNumberTextField;
@property (weak, nonatomic) IBOutlet UILabel *confNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *confUidTextField;
- (IBAction)createVoiceConf:(id)sender;
- (IBAction)createVideoConf:(id)sender;
- (IBAction)queryConf:(id)sender;
- (IBAction)joinConf:(id)sender;
- (IBAction)createJoinVoiceConf:(id)sender;
- (IBAction)createJoinVideoConf:(id)sender;

@end

//
//  ConfViewController.m
//  CloudSample
//
//  Created by Young on 15/6/24.
//  Copyright (c) 2015年 young. All rights reserved.
//

#import "ConfViewController.h"
#import "MeetingViewController.h"
#import "ParticipantModel.h"

int iOnlyConf = 0;

@interface ConfViewController () <UIAlertViewDelegate>
{
    NSString *_confUri;
    ZUINT _confId;
    NSString *_confNumber;
    NSString *_confTitle;
    BOOL _isVideo;
}
@end

@implementation ConfViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Conf" image:nil tag:150];
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(confCreateOk:) name:@MtcConfCreateOkNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(confCreateFail:) name:@MtcConfCreateDidFailNotification object:nil];
        
        [notificationCenter addObserver:self selector:@selector(confJoinOk:) name:@MtcConfJoinOkNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(confJoinFail:) name:@MtcConfJoinDidFailNotification object:nil];
        
        [notificationCenter addObserver:self selector:@selector(confQueryOk:) name:@MtcConfQueryOkNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(confQueryFail:) name:@MtcConfQueryDidFailNotification object:nil];
        
        [notificationCenter addObserver:self selector:@selector(confInviteReceived:) name:@MtcConfInviteReceivedNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(confOnly:) name:@MtcDidLogoutNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(confOnly:) name:@MtcLogoutedNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(confInviteFail:) name:@MtcConfInviteDidFailNotification object:nil];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
    
}

#pragma mark - Notification callbacks
- (void)confOnly:(NSNotification *)notification
{
    _confNumberLabel.text = nil;
    _confNumberTextField.text = nil;
    _confPasswordTextField.text = nil;
    _confTitleTextField.text = nil;
    iOnlyConf = 0;
}

- (void)confCreateOk:(NSNotification *)notification
{
    _confUri = [notification.userInfo objectForKey:@MtcConfUriKey];
    _confNumber = [notification.userInfo objectForKey:@MtcConfNumberKey];
    NSLog(@"ConfUri = %@, ConfNumber = %@", _confUri, _confNumber);
    self.confNumberLabel.text = [NSString stringWithFormat:@"ConfNo: %@", _confNumber];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Create conference successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)confCreateFail:(NSNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Create confernece fail" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)confJoinOk:(NSNotification *)notification
{
    NSArray *partArray = [notification.userInfo objectForKey:@MtcConfPartpLstKey];
    NSLog(@"partArray: %@", partArray);
    NSMutableArray *modelArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in partArray) {
        ParticipantModel *model = [[ParticipantModel alloc] init];
        model.userUri = dict[@MtcConfUserUriKey];
        ZCONST ZCHAR *userId = Mtc_UserGetId([model.userUri UTF8String]);
        model.username = [NSString stringWithUTF8String:userId];
        model.confState = [dict[@MtcConfStateKey] integerValue];
        model.picSize = MTC_CONF_PS_SMALL;
        model.frameRate = 15;
        model.sended = NO;
        model.volume = 30;
        [modelArray addObject:model];
    }
    iOnlyConf++;
    MeetingViewController *meetingViewController = [[MeetingViewController alloc] init];
    meetingViewController.confId = _confId;
    meetingViewController.confTitle = _confTitle;
    meetingViewController.video = _isVideo;
    meetingViewController.dataArray = modelArray;
    [self presentViewController:meetingViewController animated:YES completion:nil];
    _confUri = nil;
    _confNumberLabel.text = nil;
    
}

- (void)confJoinFail:(NSNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Join confernece fail" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)confQueryOk:(NSNotification *)notification
{
    _confUri = [notification.userInfo objectForKey:@MtcConfUriKey];
    _confTitle = [notification.userInfo objectForKey:@MtcConfTitleKey];
    _isVideo = [[notification.userInfo objectForKey:@MtcConfIsVideoKey] boolValue];
    NSLog(@"confUri: %@, title: %@, isVideo: %d", _confUri, _confTitle, _isVideo);
    NSString *message = [NSString stringWithFormat:@"Query successfully, %@ conference title: %@.", _isVideo ? @"Video" : @"Vioce", _confTitle];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)confQueryFail:(NSNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Query confernece fail" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)confInviteReceived:(NSNotification *)notification
{
    if (iOnlyConf > 0)
        return;
    _confUri = [notification.userInfo objectForKey:@MtcConfUriKey];
    _confNumber = [notification.userInfo objectForKey:@MtcConfNumberKey];
    _confTitle = [notification.userInfo objectForKey:@MtcConfTitleKey];
    _isVideo = [[notification.userInfo objectForKey:@MtcConfIsVideoKey] boolValue];
    NSString *userUri = [notification.userInfo objectForKey:@MtcConfUserUriKey];
    NSString *userName = [NSString stringWithUTF8String:Mtc_UserGetId([userUri UTF8String])];
    NSString *message = [NSString stringWithFormat:@"Received %@ conference from %@, join to the conference?", _isVideo ? @"Video" : @"Vioce", userName];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)confInviteFail:(NSNotification *)notification
{
    NSString *userUri = [notification.userInfo objectForKey:@MtcConfUserUriKey];
    NSInteger reason = [[notification.userInfo objectForKey:@MtcConfReasonKey] integerValue];
    
    ZCONST ZCHAR *userId = Mtc_UserGetId([userUri UTF8String]);
    NSString *username = [NSString stringWithUTF8String:userId];
    
    NSString *message = nil;
    if (reason == EN_MTC_CONF_REASON_DECLINE) {
        message = @"Participant is busy";
    } else if (reason == EN_MTC_CONF_REASON_ACCOUNT_NOT_EXIST) {
        message = @"Participant not exist";
    }else if (reason == EN_MTC_CONF_REASON_NETWORK){
        message = @"Please check network connection";
    }else {
        message = [[NSString alloc] initWithFormat:@"reason: %d", (int)reason];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[NSString alloc] initWithFormat:@"%@ %@", @"Invite Failed!", username] message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];

}

- (void)tapAction
{
    [self.view endEditing:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"OK"]) {
        if (_confUri && _confUri.length > 0) {
            _confId = _confId = Mtc_ConfJoin([_confUri UTF8String], 0);
            NSLog(@"ConfId = %d", _confId);
        }
    }
}

- (void)createConfWithVideo:(BOOL)isVideo
{
    _confTitle = _confTitleTextField.text;
    NSString *password = _confPasswordTextField.text;
    ZINT ret = Mtc_ConfCreateEx(0, [_confTitle UTF8String], [password UTF8String], isVideo);
    NSLog(@"ConfCreate ret = %d",ret);
    _isVideo = isVideo;
    [self.view endEditing:YES];
}

- (IBAction)createVoiceConf:(id)sender {
    [self createConfWithVideo:NO];
}

- (IBAction)createVideoConf:(id)sender {
    [self createConfWithVideo:YES];
}

- (IBAction)queryConf:(id)sender {
    _confNumber = _confNumberTextField.text;
    ZINT ret = Mtc_ConfQuery(0, [_confNumber intValue]);
    NSLog(@"ConfQuery ret = %d", ret);
}

- (IBAction)joinConf:(id)sender {
    if (_confUri && _confUri.length > 0) {
        _confId = Mtc_ConfJoin([_confUri UTF8String], 0);
        NSLog(@"ConfId = %d", _confId);
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You must create conference firstly" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)createJoinConfWithVideo:(BOOL)isVideo
{
    _confTitle = _confUidTextField.text;
    _confId = Mtc_ConfJoinX([_confTitle UTF8String], 0, NULL, ZTRUE);
    NSLog(@"ConfCreate ret = %d",_confId);
    _isVideo = isVideo;
    [self.view endEditing:YES];
}

- (IBAction)createJoinVoiceConf:(id)sender
{
    [self createJoinConfWithVideo:NO];
}

- (IBAction)createJoinVideoConf:(id)sender
{
    [self createJoinConfWithVideo:YES];
}


@end

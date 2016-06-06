//
//  MeetingViewController.m
//  CloudSample
//
//  Created by Young on 15/6/25.
//  Copyright (c) 2015年 young. All rights reserved.
//

#import "MeetingViewController.h"
#import "LoginViewController.h"
#import "ConfStatisticsView.h"
#import "ParticipantModel.h"
#import "ConfCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface MeetingViewController () <UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIActionSheetDelegate>
{
    NSString *_username;
    ConfStatisticsView *_confStatisticsView;
    NSInteger _index;
    
    UIView *_fullView;
    UIButton *_backButton;
    UIButton *_picSizeButton;
    UIButton *_statisticButton;
    UILabel *_rateLabel;
    UIStepper *_rateStepper;
    UIActionSheet *_picSizeSheet;
    AVAudioSession *_audioSession;
    
    UIAlertView *_inviteAlertView;
    UIAlertView *_didLeaveAlertView;
}
@end

@implementation MeetingViewController

- (UILabel *)confTitleLabel
{
    if (!_confTitleLabel) {
        _confTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 180) / 2, 20, 180, 20)];
        _confTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _confTitleLabel;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 45, kScreenWidth, kScreenHeight - 80 - 15) collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[ConfCollectionViewCell class] forCellWithReuseIdentifier:@"collectionCellId"];
    }
    return _collectionView;
}

- (UIView *)menuView
{
    if (!_menuView) {
        _menuView = [[[NSBundle mainBundle] loadNibNamed:@"MenuView" owner:self options:nil] lastObject];
        _menuView.frame = CGRectMake(0, kScreenHeight - 60, kScreenWidth, 200);
    }
    return _menuView;
}

- (IBAction)showMenu:(UIButton *)sender;
{
    sender.selected = !sender.isSelected;
    [UIView animateWithDuration:1 animations:nil completion:^(BOOL finished) {
        _menuView.frame = CGRectMake(0, sender.isSelected ? (kScreenHeight - 200) : (kScreenHeight - 60), kScreenWidth, 200);
    }];
}

- (IBAction)startMediaSend:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    [sender setTitle:sender.isSelected ? @"StopMedia" : @"StartMedia" forState:UIControlStateNormal];
    if (sender.isSelected) {
        Mtc_ConfStartSend(_confId, MTC_CONF_MEDIA_ALL);
    } else {
        Mtc_ConfStopSend(_confId, MTC_CONF_MEDIA_ALL);
    }
}

- (IBAction)cameraSwitch:(UIButton *)sender {
    if (self.isVideo) {            
	    sender.selected = !sender.isSelected;
	    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@", _username];
	    NSArray *filteredArray = [_dataArray filteredArrayUsingPredicate:predicate];
	    if (filteredArray.count > 0) {
	        ParticipantModel *model = filteredArray.firstObject;
	        if (sender.isSelected) {
	            [model cameraSwitch:ZmfVideoCaptureBack];
	            Zmf_VideoCaptureStopAll();
	            [self videoCaptureStart:NO];
	        } else {
	            [model cameraSwitch:ZmfVideoCaptureFront];
	            Zmf_VideoCaptureStopAll();
	            [self videoCaptureStart:YES];
	        }
	    }
	    [sender setTitle:sender.isSelected ? @"FrontCam" : @"BackCam" forState:UIControlStateNormal];
    }
    else{
        [sender setEnabled:NO];
        sender.backgroundColor = [UIColor grayColor];
    }
}

- (IBAction)speaker:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [_audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    } else {
        [_audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }
    [sender setTitle:sender.isSelected ? @"SpeakerOff" : @"SpeakerOn" forState:UIControlStateNormal];
}

- (IBAction)inviteUser:(id)sender {
    _inviteAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Enter username" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    _inviteAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [_inviteAlertView show];
}

- (IBAction)leaveConf:(id)sender {
    ZINT ret = Mtc_ConfLeave(_confId);
    NSLog(@"ConfLeave ret = %d",ret);
    
    if (self.isVideo) {
        Zmf_VideoCaptureStopAll();
        for (ParticipantModel *model in _dataArray) {
            [model stopRender];
        }    
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [self audioStop];
    }];
}

- (void)ConfStatisticsViewShow
{
    if (_confStatisticsView) {
        return;
    }
    ParticipantModel *model = _dataArray[_index];
    CGRect callViewframe = self.view.frame;
    callViewframe.origin.y = callViewframe.size.height;
    _confStatisticsView = [[ConfStatisticsView alloc] initWithFrame:callViewframe confId:_confId parameter:[model.userUri UTF8String]];
    [self.view addSubview:_confStatisticsView];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tapGR.cancelsTouchesInView = NO;
    [_confStatisticsView.textView addGestureRecognizer:tapGR];
    
    CGRect frame = _confStatisticsView.frame;
    frame.origin.y = 0;
    [UIView animateWithDuration:0.3
                     animations:^{
                         _confStatisticsView.frame = frame;
                     }];
}

- (void)tap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:_confStatisticsView];
    if (CGRectContainsPoint(_confStatisticsView.segmentedControl.frame, point)) {
        return;
    }
    
    [self ConfStatisticsViewDismiss];
}

- (void)ConfStatisticsViewDismiss
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ConfStatisticsViewDismissNotification" object:nil];
    [_confStatisticsView removeFromSuperview];
    _confStatisticsView = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _username = [userDefaults stringForKey:@"username"];
    _audioSession = [AVAudioSession sharedInstance];
    [self audioStart];
    if (self.isVideo) {
        [self videoCaptureStart:YES];
        
        for (ParticipantModel *model in _dataArray) {
            if (![model.username isEqualToString:_username]) {
                char videoJson[1024];
                sprintf(videoJson, "{\"MtcConfUserUriKey\" : \"%s\", \"MtcConfPictureSizeKey\" : %d, \"MtcConfFrameRateKey\" : %d}", [model.userUri UTF8String], model.picSize, model.frameRate);
                printf("videoJson: %s\n",videoJson);
                Mtc_ConfCommand(_confId, MtcConfCmdRequestVideo, videoJson);
                model.renderId = model.userUri;
            } else {
                model.renderId = [NSString stringWithUTF8String:ZmfVideoCaptureFront];
            }
        }
    }
    
    [self.view addSubview:self.confTitleLabel];
    _confTitleLabel.text = [NSString stringWithFormat:@"Title: %@", _confTitle];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.menuView];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(confInviteOk:) name:@MtcConfInviteOkNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(confInviteFail:) name:@MtcConfInviteDidFailNotification object:nil];
    
    [notificationCenter addObserver:self selector:@selector(confJoined:) name:@MtcConfJoinedNotification object:nil];
    
    [notificationCenter addObserver:self selector:@selector(confDidLeave:) name:@MtcConfDidLeaveNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(confLeaved:) name:@MtcConfLeavedNotification object:nil];
    
    [notificationCenter addObserver:self selector:@selector(confKickOk:) name:@MtcConfKickOkNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(confKickFail:) name:@MtcConfKickDidFailNotification object:nil];
    
    [notificationCenter addObserver:self selector:@selector(confVolumeChanged:) name:@MtcConfVolumeChangedNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(confDestory:) name:@MtcLogoutedNotification object:nil];
}

- (void)confDestory:(NSNotification *)notification
{
    if (self.isVideo) {
        if (_fullView) {
            Zmf_VideoRenderRemoveAll((__bridge void *)_fullView);
            Zmf_VideoRenderStop((__bridge void *)_fullView);
            [_fullView removeFromSuperview];
            _fullView = nil;
        }
        Zmf_VideoCaptureStopAll();
        for (ParticipantModel *model in _dataArray) {
            [model stopRender];
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [self audioStop];
    }];
}

- (void)confInviteOk:(NSNotification *)notification
{
    NSLog(@"confInviteOk");
}

- (void)confInviteFail:(NSNotification *)notification
{
    NSLog(@"confInviteFail");
}

- (void)confJoined:(NSNotification *)notification
{
    ParticipantModel *model = [[ParticipantModel alloc] init];
    model.userUri = [notification.userInfo objectForKey:@MtcConfUserUriKey];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userUri == %@", model.userUri];
    NSArray *filteredArray = [_dataArray filteredArrayUsingPredicate:predicate];
    if (filteredArray.count == 0) {
        model.username = [NSString stringWithUTF8String:Mtc_UserGetId([model.userUri UTF8String])];
        model.confState = [[notification.userInfo objectForKey:@MtcConfStateKey] integerValue];
        model.picSize = MTC_CONF_PS_SMALL;
        model.frameRate = 15;
        model.sended = NO;
        model.volume = 30;
        if (self.isVideo) {
            char videoJson[1024];
            sprintf(videoJson, "{\"MtcConfUserUriKey\" : \"%s\", \"MtcConfPictureSizeKey\" : %d, \"MtcConfFrameRateKey\" : %d}", [model.userUri UTF8String], model.picSize, model.frameRate);
            printf("videoJson: %s\n",videoJson);
            Mtc_ConfCommand(_confId, MtcConfCmdRequestVideo, videoJson);
            model.renderId = model.userUri;
        }
        
        [_dataArray addObject:model];
        NSUInteger index = [_dataArray indexOfObject:model];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [_collectionView insertItemsAtIndexPaths:@[indexPath]];
    }
}

- (void)confDidLeave:(NSNotification *)notification
{
    ZINT reason = [[notification.userInfo objectForKey:@MtcConfReasonKey] intValue];
    NSString *message = nil;
    iOnlyConf--;
    if (reason == EN_MTC_CONF_REASON_LEAVED) {
        return;
    } else if (reason == EN_MTC_CONF_REASON_KICKED) {
        message = @"You've been kicked out of conference!";
    }else if (reason == EN_MTC_CONF_REASON_OFFLINE){
        message = @"You are offline!";
    }
    
    _didLeaveAlertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [_didLeaveAlertView show];
}

- (void)confLeaved:(NSNotification *)notification
{
    NSString *leaveUserUri = [notification.userInfo objectForKey:@MtcConfUserUriKey];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userUri == %@", leaveUserUri];
    NSArray *filteredArray = [_dataArray filteredArrayUsingPredicate:predicate];
    if (filteredArray.count > 0) {
        ParticipantModel *model = [filteredArray firstObject];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[_dataArray indexOfObject:model] inSection:0];
        if (self.isVideo) {
            if(_fullView) {
                if (_confStatisticsView) {
                    [self ConfStatisticsViewDismiss];
                }
                [self backAction];
            }
                
            [model stopRender];
        }
        [_dataArray removeObject:model];
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    }
}

- (void)confKickOk:(NSNotification *)notification
{
    NSLog(@"confKickOk");
}

- (void)confKickFail:(NSNotification *)notification
{
    NSLog(@"confKickFail");
}

- (void)confVolumeChanged:(NSNotification *)notification
{
    //NSDictionary *dict = notification.userInfo;
    //NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    //NSMutableArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    //NSLog(@"%@", array);
    NSArray* array= [notification.userInfo objectForKey:@MtcConfPartpVolumeLstKey];
    NSMutableArray *indexArray = [[NSMutableArray alloc] init];
    for (NSDictionary *volumeDict in array)
    {
        NSString *volumeUserUri = [volumeDict objectForKey:@MtcConfUserUriKey];
        int vol = [[volumeDict objectForKey:@MtcConfVolumeKey] intValue];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userUri == %@",volumeUserUri];
        NSArray *filterArray = [_dataArray filteredArrayUsingPredicate:predicate];
        if (filterArray.count > 0) {
            ParticipantModel *model = [filterArray firstObject];
            model.volume = vol;
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[_dataArray indexOfObject:model] inSection:0];
            [indexArray addObject:indexPath];
        }
    }
    [_collectionView reloadItemsAtIndexPaths:indexArray];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ConfCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCellId" forIndexPath:indexPath];
    [cell fillData:_dataArray[indexPath.item] isVideo:self.isVideo];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _index = indexPath.item;
    ParticipantModel *model = _dataArray[_index];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Statistic", @"Kick", model.isSended ? @"StopForward" : @"StartForward", self.isVideo ? @"FullScreen" : nil, nil];
    [sheet showInView:self.view];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kScreenWidth / 2 - 10, 120);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

#pragma  mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if ([actionSheet isEqual:_picSizeSheet]) {
        ParticipantModel *model = _dataArray[_index];
        NSString *title = nil;
        switch (buttonIndex) {
            case 0: {
                model.picSize = MTC_CONF_PS_MIN;
                title = @"Min";
                }
                break;
            case 1: {
                model.picSize = MTC_CONF_PS_SMALL;
                title = @"Small";
                }
                break;
            case 2: {
                model.picSize = MTC_CONF_PS_LARGE;
                title = @"Large";
                }
                break;
            case 3: {
                model.picSize = MTC_CONF_PS_MAX;
                title = @"Max";
                }
                break;
            case 4:
                return;
            default:
                break;
        }
        
        [_picSizeButton setTitle:title forState:UIControlStateNormal];
        char videoJson[1024];
        sprintf(videoJson, "{\"MtcConfUserUriKey\" : \"%s\", \"MtcConfPictureSizeKey\" : %d, \"MtcConfFrameRateKey\" : %d}", [model.userUri UTF8String], model.picSize, model.frameRate);
        printf("videoJson: %s\n",videoJson);
        Mtc_ConfCommand(_confId, MtcConfCmdRequestVideo, videoJson);
        return;
    }
    
    ParticipantModel *model = _dataArray[_index];
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Statistic"]) {
        [self ConfStatisticsViewShow];
        
    } else if ([buttonTitle isEqualToString:@"Kick"]) {
        Mtc_ConfKickUser(_confId, [model.userUri UTF8String]);
        
    } else if (buttonIndex == 2) {
        model.sended = !model.isSended;
        char videoJson[1024];
        sprintf(videoJson, "{\"MtcConfUserUriKey\" : \"%s\", \"MtcConfMediaOptionKey\" : 3}", [model.userUri UTF8String]);
        printf("videoJson: %s\n",videoJson);
        Mtc_ConfCommand(_confId, model.isSended ? MtcConfCmdStartForward : MtcConfCmdStopForward, videoJson);
    } else if ([buttonTitle isEqualToString:@"FullScreen"]) {
        
        if (!_fullView) {
            _fullView = [[UIView alloc] initWithFrame:self.view.frame];
            Zmf_VideoRenderStart((__bridge void *)(_fullView), ZmfRenderViewFx);
            NSString *renderId = model.renderId;
            NSLog(@"renderId: %@", renderId);
            Zmf_VideoRenderAdd((__bridge void *)(_fullView), [renderId UTF8String], 0, ZmfRenderFullScreen);
            [self.view addSubview:_fullView];
        }
        
        if (!_backButton) {
            _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _backButton.frame = CGRectMake(10, 30, 60, 40);
            _backButton.backgroundColor = [UIColor blueColor];
            [_backButton setTitle:@"back" forState:UIControlStateNormal];
            [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_backButton];
        }
        
        if (!_picSizeButton) {
            _picSizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _picSizeButton.frame = CGRectMake(10, 80, 60, 40);
            _picSizeButton.backgroundColor = [UIColor blueColor];
            NSString *title = nil;
            switch (model.picSize) {
                case MTC_CONF_PS_MIN:
                    title = @"Min";
                    break;
                case MTC_CONF_PS_SMALL:
                    title = @"Small";
                    break;
                case MTC_CONF_PS_LARGE:
                    title = @"Large";
                    break;
                case MTC_CONF_PS_MAX:
                    title = @"Max";
                    break;
                default:
                    break;
            }
            
            [_picSizeButton setTitle:title forState:UIControlStateNormal];
            [_picSizeButton addTarget:self action:@selector(chooseSize) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_picSizeButton];
        }
        
        if (!_statisticButton) {
            _statisticButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _statisticButton.frame = CGRectMake(kScreenWidth - 70, 30, 60, 40);
            _statisticButton.backgroundColor = [UIColor blueColor];
            [_statisticButton setTitle:@"Stat" forState:UIControlStateNormal];
            [_statisticButton addTarget:self action:@selector(ConfStatisticsViewShow) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_statisticButton];
        }
        
        if (!_rateLabel) {
            _rateLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 140) / 2, 30, 140, 30)];
            _rateLabel.backgroundColor = [UIColor blueColor];
            _rateLabel.text = [NSString stringWithFormat:@"FrameRate: %d", model.frameRate];
            _rateLabel.textAlignment = NSTextAlignmentCenter;
            _rateLabel.textColor = [UIColor whiteColor];
            [self.view addSubview:_rateLabel];
        }

        if (!_rateStepper) {
            _rateStepper = [[UIStepper alloc] initWithFrame:CGRectMake((kScreenWidth - 94) / 2, 65, 94, 5)];
            _rateStepper.minimumValue = 1.0;
            _rateStepper.maximumValue = 30.0;
            [_rateStepper setValue:model.frameRate];
            [_rateStepper addTarget:self action:@selector(touchEnd:) forControlEvents:UIControlEventTouchUpInside];
            [_rateStepper addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
            [self.view addSubview:_rateStepper];
        }

    }
}

- (void)backAction
{
    if (_fullView) {
        Zmf_VideoRenderRemoveAll((__bridge void *)_fullView);
        Zmf_VideoRenderStop((__bridge void *)_fullView);
        [_fullView removeFromSuperview];
        _fullView = nil;
    }
    
    if (_backButton) {
        [_backButton removeFromSuperview];
        _backButton = nil;
    }
    
    if (_picSizeButton) {
        [_picSizeButton removeFromSuperview];
        _picSizeButton = nil;
    }
    
    if (_statisticButton) {
        [_statisticButton removeFromSuperview];
        _statisticButton = nil;
    }
    if (_rateLabel) {
        [_rateLabel removeFromSuperview];
        _rateLabel = nil;
    }
    
    if (_rateStepper) {
        [_rateStepper removeFromSuperview];
        _rateStepper = nil;
    }
}

- (void)chooseSize
{
    _picSizeSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Min", @"Small" ,@"Large", @"Max", nil];
    [_picSizeSheet showInView:self.view];
}

- (void)touchEnd:(UIStepper *)sender
{
    ParticipantModel *model = _dataArray[_index];
    model.frameRate = (int)sender.value;
    char videoJson[1024];
    sprintf(videoJson, "{\"MtcConfUserUriKey\" : \"%s\", \"MtcConfPictureSizeKey\" : %d, \"MtcConfFrameRateKey\" : %d}", [model.userUri UTF8String], model.picSize, model.frameRate);
    printf("videoJson: %s\n",videoJson);
    Mtc_ConfCommand(_confId, MtcConfCmdRequestVideo, videoJson);
}

- (void)changeValue:(UIStepper *)sender
{
    _rateLabel.text = [NSString stringWithFormat:@"FrameRate: %d", (int)sender.value];
}


#pragma  mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:_didLeaveAlertView]) {
        if (buttonIndex == 0) {
            if (self.isVideo) {
                if (_fullView) {
                    Zmf_VideoRenderRemoveAll((__bridge void *)_fullView);
                    Zmf_VideoRenderStop((__bridge void *)_fullView);
                    [_fullView removeFromSuperview];
                    _fullView = nil;
                }
                Zmf_VideoCaptureStopAll();
                for (ParticipantModel *model in _dataArray) {
                    [model stopRender];
                }
            }
            [self dismissViewControllerAnimated:YES completion:^{
                [self audioStop];
            }];
        }
        return;
    }
    
    if ([alertView isEqual:_inviteAlertView]) {
        NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
        if ([buttonTitle isEqualToString:@"OK"]) {
            UITextField *usernameField = [alertView textFieldAtIndex:0];
            NSString *username = usernameField.text;
            if (username && username.length > 0) {
                ZINT ret = Mtc_ConfInviteUser(_confId, Mtc_UserFormUri(EN_MTC_USER_ID_USERNAME, [username UTF8String]));
                NSLog(@"ConfInviteUser ret = %d",ret);
            }
        }
        return;
    }
}


#pragma mark - ZMF Audio
- (void)audioStart
{
    ZBOOL bAec = Mtc_MdmGetOsAec();
    const char *pcId = bAec ? ZmfAudioDeviceVoice : ZmfAudioDeviceRemote;
    ZBOOL bAgc = Mtc_MdmGetOsAgc();
    int ret = Zmf_AudioInputStart(pcId, 0, 0, bAec ? ZmfAecOn : ZmfAecOff, bAgc ? ZmfAgcOn : ZmfAgcOff);
    if (ret == 0) {
        ret = Zmf_AudioOutputStart(pcId, 0, 0);
    }
}

- (void)audioStop
{
    Zmf_AudioInputStopAll();
    Zmf_AudioOutputStopAll();
}

#pragma mark - ZMF Video
- (void)videoCaptureStart:(BOOL)isFront
{
    const char *pcCapture = isFront ? ZmfVideoCaptureFront : ZmfVideoCaptureBack;
    unsigned int iVideoCaptureWidth;
    unsigned int iVideoCaptureHeight;
    unsigned int iVideoCaptureFrameRate;
    Mtc_MdmGetCaptureParms(&iVideoCaptureWidth, &iVideoCaptureHeight, &iVideoCaptureFrameRate);
    Zmf_VideoCaptureStart(pcCapture, iVideoCaptureWidth, iVideoCaptureHeight, iVideoCaptureFrameRate);
    Mtc_ConfSetVideoCapture(_confId, pcCapture);
}
@end

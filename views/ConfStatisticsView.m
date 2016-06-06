//
//  ConfStatisticsView.m
//  CloudSample
//
//  Created by Young on 15/3/12.
//  Copyright (c) 2015年 young. All rights reserved.
//

#import "ConfStatisticsView.h"

@implementation ConfStatisticsView
{
    ZUINT _confId;
    const char *_parameter;
    BOOL _isConf;
}
@synthesize
    callId = _callId,
    segmentedControl = _segmentedControl,
    textView = _textView;

- (void)cancelStatistics
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setStatistics) object:nil];
}

- (void)setStatistics
{
    [self segmentedControlValueChanged:_segmentedControl];
    [self performSelector:@selector(setStatistics) withObject:nil afterDelay:1];
}

- (void)addSegmentedControl
{
    _segmentedControl = [[UISegmentedControl alloc] initWithItems: @[_isConf ? @"Media" : @"Voice", _isConf ? @"Config" : @"Video", @"NAT"]];
    _segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [_segmentedControl setWidth:75 forSegmentAtIndex:0];
    [_segmentedControl setWidth:75 forSegmentAtIndex:1];
    [_segmentedControl setWidth:75 forSegmentAtIndex:2];
    [_segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    _segmentedControl.selectedSegmentIndex = 0;
    CGRect frame = _segmentedControl.frame;
    frame.origin.y = 20;
    frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
    _segmentedControl.frame = frame;
    
    [self addSubview:_segmentedControl];
}

- (void)segmentedControlValueChanged:(id)sender
{
    ZCONST ZCHAR *stat = nil;
    switch ([sender selectedSegmentIndex]) {
        case 0:
            stat = _isConf ? Mtc_ConfGetStatistics(_confId, MTC_CONF_STS_PARTICIPANT, _parameter) : Mtc_CallGetAudioStat(self.callId);
            break;
        case 1:
            stat = _isConf ? Mtc_ConfGetStatistics(_confId, MTC_CONF_STS_CONFIG, NULL) : Mtc_CallGetVideoStat(self.callId);
            break;
        case 2: {
            if (_isConf) {
                ZCONST ZCHAR *netStr = Mtc_ConfGetStatistics(_confId, MTC_CONF_STS_NETWORK, NULL);
                ZCONST ZCHAR *tranStr = Mtc_ConfGetStatistics(_confId, MTC_CONF_STS_NETWORK, NULL);
                ZCHAR tempStr[1024];
                sprintf(tempStr, "%s\n---------------\n%s", netStr, tranStr);
                stat = (ZCONST ZCHAR *)tempStr;
            } else {
                stat = Mtc_CallGetMptStat(self.callId);
            }
        }
            break;
    }
    
    if (stat && strlen(stat)) {
        _textView.text = [NSString stringWithUTF8String:stat];
    } else {
        _textView.text = @"Not Running";
    }
}

- (void)addTextView
{
    CGRect frame = self.frame;
    frame.origin.y = _segmentedControl.frame.origin.y + _segmentedControl.frame.size.height;
    frame.size.height -= frame.origin.y;
    _textView = [[UITextView alloc] initWithFrame:frame];
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _textView.editable = NO;
    _textView.font = [UIFont fontWithName:@"Courier" size:10];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.editable = NO;
    
    [self addSubview:_textView];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (_segmentedControl) {
        CGRect segmentedControlFrame = _segmentedControl.frame;
        segmentedControlFrame.origin.x = (self.frame.size.width - segmentedControlFrame.size.width) / 2;
        _segmentedControl.frame = segmentedControlFrame;
    }
}

- (id)initWithFrame:(CGRect)frame callId:(ZUINT)callId
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.callId = callId;
        self.frame = frame;
        _isConf = NO;
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSegmentedControl];
        [self addTextView];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setStatistics];
        });
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelStatistics) name:@"ConfStatisticsViewDismissNotification" object:nil];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame confId:(ZUINT)confId parameter:(const char *)parameter
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.frame = frame;
        _confId = confId;
        _parameter = parameter;
        _isConf = YES;
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSegmentedControl];
        [self addTextView];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setStatistics];
        });
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelStatistics) name:@"ConfStatisticsViewDismissNotification" object:nil];
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

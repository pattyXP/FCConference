//
//  StatisticsView.h
//  CloudSample
//
//  Created by Young on 15/3/12.
//  Copyright (c) 2015年 young. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfStatisticsView : UIView

@property (nonatomic, assign) ZUINT callId;
@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, retain) UITextView *textView;

- (id)initWithFrame:(CGRect)frame callId:(ZUINT)callId;
- (id)initWithFrame:(CGRect)frame confId:(ZUINT)confId parameter:(const char *)parameter;

@end

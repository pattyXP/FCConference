//
//  MeetingViewController.h
//  CloudSample
//
//  Created by Young on 15/6/25.
//  Copyright (c) 2015年 young. All rights reserved.
//

#import <UIKit/UIKit.h>
extern int iOnlyConf;
@interface MeetingViewController : UIViewController

@property (nonatomic, assign) ZUINT confId;
@property (nonatomic, retain) NSString *confTitle;
@property (nonatomic, getter=isVideo) BOOL video;
@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, retain) NSMutableArray *dataArray;
@property (nonatomic, retain) UIView *menuView;
@property (nonatomic, retain) UILabel *confTitleLabel;

@end

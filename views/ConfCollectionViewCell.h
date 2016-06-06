//
//  ConfCollectionViewCell.h
//  CloudSample
//
//  Created by Young on 15/6/26.
//  Copyright (c) 2015年 young. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParticipantModel.h"

@interface ConfCollectionViewCell : UICollectionViewCell

@property (nonatomic, retain) UILabel *usernameLabel;
@property (nonatomic, retain) UILabel *volumeLabel;

- (void)fillData:(ParticipantModel *)model isVideo:(BOOL)isVideo;

@end

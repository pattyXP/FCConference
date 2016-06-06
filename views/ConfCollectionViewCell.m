//
//  ConfCollectionViewCell.m
//  CloudSample
//
//  Created by Young on 15/6/26.
//  Copyright (c) 2015年 young. All rights reserved.
//

#import "ConfCollectionViewCell.h"

@implementation ConfCollectionViewCell

- (UILabel *)usernameLabel
{
    if (!_usernameLabel) {
        _usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.frame.size.height - 30, self.frame.size.width - 20, 30)];
        _usernameLabel.backgroundColor = [UIColor clearColor];
    }
    return _usernameLabel;
}

- (UILabel *)volumeLabel
{
    if (!_volumeLabel) {
        _volumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 55, self.frame.size.height - 30, self.frame.size.width - 20, 30)];
        _volumeLabel.backgroundColor = [UIColor clearColor];
    }
    return _volumeLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.usernameLabel];
        [self.contentView addSubview:self.volumeLabel];
    }
    return self;
}

- (void)fillData:(ParticipantModel *)model isVideo:(BOOL)isVideo
{
    _usernameLabel.text = model.username;
    _volumeLabel.text = [NSString stringWithFormat:@"vol:%d",model.volume];
    if (isVideo)
        [model setSuperView:self.contentView];
    else
        self.contentView.backgroundColor = [UIColor redColor];
}

@end

//
//  ParticipantModel.h
//  CloudSample
//
//  Created by Young on 15/6/26.
//  Copyright (c) 2015年 young. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParticipantModel : NSObject

@property (nonatomic, retain) NSString *userUri;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *renderId;
@property (nonatomic, assign) NSInteger confState;
@property (nonatomic, assign) int picSize;
@property (nonatomic, assign) int frameRate;
@property (nonatomic, assign) int volume;
@property (nonatomic, getter=isSended) BOOL sended;

- (void)setSuperView:(UIView*)view;
- (void)stopRender;
- (void)cameraSwitch:(ZCONST ZCHAR *)newRenderId;
@end

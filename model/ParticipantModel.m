//
//  ParticipantModel.m
//  CloudSample
//
//  Created by Young on 15/6/26.
//  Copyright (c) 2015年 young. All rights reserved.
//

#import "ParticipantModel.h"

@implementation ParticipantModel
{
    UIView *_renderView;
}

- (void)setSuperView:(UIView*)view
{
    if (!view) {
        if (_renderView)
            [_renderView removeFromSuperview];
        return;
    }
    
    if (!_renderView) {
        _renderView = [[UIView alloc] initWithFrame:view.bounds];
        Zmf_VideoRenderStart((__bridge void *)(_renderView), ZmfRenderView);
        Zmf_VideoRenderAdd((__bridge void *)(_renderView), [_renderId UTF8String], 0, ZmfRenderFullScreen);
    }
    else if (_renderView.superview == view)
        return;
    else
        [_renderView removeFromSuperview];
    
    [view insertSubview:_renderView atIndex:0];
}

- (void)stopRender
{
    if(_renderView) {
        Zmf_VideoRenderStop((__bridge void *)_renderView);
        Zmf_VideoRenderRemoveAll((__bridge void *)_renderView);
        [_renderView removeFromSuperview];
        _renderView = nil;
    }
}

- (void)cameraSwitch:(ZCONST ZCHAR *)newRenderId
{
    if (_renderView) {
        Zmf_VideoRenderReplace((__bridge void *)(_renderView), [_renderId UTF8String], newRenderId);
    }
    _renderId = [NSString stringWithUTF8String:newRenderId];
}

@end

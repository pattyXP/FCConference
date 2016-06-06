//
//  MtcDocDelegate.h
//  JusDoc
//
//  Created by Fiona on 1/14/16.
//  Copyright © 2016 juphoon. All rights reserved.
//

#ifndef JusDocManager_h
#define JusDocManager_h

#import <Foundation/Foundation.h>
#import <JusDoc/JusDoc.h>

@protocol JusDocDelegate

- (void) DidCreate:(JCallId)callId;
- (void) RequestToStart:(JCallId)callId;
- (void) RequestToStop:(JCallId)callId;

@end

@interface JusDocManager : NSObject

+ (void) Init:(id<JusDocDelegate>)delegate;
+ (void) Start:(JCallId)callId;
+ (id) Start:(JCallId)callId displayHeight:(CGFloat)height;
+ (void) Stop:(JCallId)callId;

@end

#endif // JusDocManager_h

//
//  JusPush.h
//  JusLogin
//
//  Created by Fiona on 10/19/15.
//  Copyright © 2015 Fiona. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MtcPushManager : NSObject 

+ (void) SetUpWithOption: (NSDictionary *)launchOptions;
+ (void) RegisterForRemoteNotificationsTypes:(NSUInteger) types categories: (NSSet *)categories;
+ (void) RegisterDeviceToken:(NSData *)deviceToken;
+ (void) HandleRemoteNotifications: (NSDictionary *)userInfo;

+ (Boolean) SetPayloadForCall:(NSString *)payload Expiration:(int)seconds;
+ (Boolean) SetPayloadForImText:(NSString *)payload Expiration:(int)seconds;
+ (Boolean) SetPayloadForImFile:(NSString *)payload Expiration:(int)seconds;
+ (Boolean) SetPayloadForImImage:(NSString *)payload Expiration:(int)seconds;
+ (Boolean) SetPayloadForImVoice:(NSString *)payload Expiration:(int)seconds;
+ (Boolean) SetPayloadForImVideo:(NSString *)payload Expiration:(int)seconds;

@end

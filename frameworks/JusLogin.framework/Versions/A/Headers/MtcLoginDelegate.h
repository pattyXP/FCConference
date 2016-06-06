//
//  MtcLoginDelegate.h
//  CloudSample
//
//  Created by Fiona on 10/12/15.
//  Copyright © 2015 young. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LoginFailedReason) {
    AccountExist = 0,
    AccountNotExist,
    AuthCodeError,
    AuthCodeExpired,
    AuthBlocked,
    UnknownReason,
};

typedef NS_ENUM(NSInteger, QueryFailedReason) {
    UserNotFound = 0,
    NoProperty,
};

@protocol MtcLoginDelegate <NSObject>

@required

- (void)loginOk;
- (void)loginFailed:(NSInteger)reason;
- (void)didLogout;
- (void)logouted;
- (void)authRequire:(NSString *)account withNonce:(NSString *)nonce;
- (void)queryLoginInfoOk:(NSString *)user
                  status:(NSString *)status
                    date:(NSDate *)date
                   brand:(NSString *)brand
                   model:(NSString *)model
                 version:(NSString *)version
              appVersion:(NSString *)appVersion;
- (void)queryLoginInfoFailed:(NSInteger)reason;

@end

@interface MtcLoginManager : NSObject 

+ (void) Init;
+ (void) Set:(id<MtcLoginDelegate>) loginDelegate;

+ (void) EnableAutoLogin:(BOOL)enabled;

+ (int) Login:(NSString *)user password:(NSString *)password server:(NSString *)server;
+ (void) Logout;

+ (void) PromptAuthCode:(NSString *)authCode;
+ (int) QueryLoginInfo:(NSString *)user;

@end

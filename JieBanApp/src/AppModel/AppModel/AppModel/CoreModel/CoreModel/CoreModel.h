//
//  CoreModel.h
//  CoreModel
//
//  Created by wangming on 16/7/12.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "KCConstants_string.h"
#import "RXThirdPart.h"


@protocol CoreModelDelegate <NSObject>

//**************************************通话***********************************
-(void)showErrorWithStatus:(NSString*) str;

-(void)setDataWithType:(NSString*)type withData:(id) data withCover:(BOOL) isCover;
@end

@interface CoreModel : NSObject
@property (nonatomic, strong) ECDevice * device;
@property (nonatomic, strong) NSString* userName;
@property (nonatomic, strong) NSString* userPhoneNum;
@property (nonatomic, weak) id<CoreModelDelegate,ECDeviceDelegate> delegate;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(CoreModel);

//根据登录信息登录connector
-(void)login:(NSDictionary*) loginInfo :(void(^)(NSError* error)) LoginCompletion;
-(void)reLogin:(void(^)(NSError* error)) LoginCompletion;

-(void)logout:(void(^)(NSError* error)) LogoutCompletion;
- (void)playRecMsgSound:(NSString *)sessionId isChat:(BOOL)isChat;
@end

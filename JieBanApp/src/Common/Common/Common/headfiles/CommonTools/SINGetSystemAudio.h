//
//  SINGetSystemAudio.h
//  guodiantong
//
//  Created by zhaozhibo on 15/1/27.
//  Copyright (c) 2015年 guodiantong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>
@interface SINGetSystemAudio : NSObject
+(id)shareManager;
//震动kSystemSoundID_Vibrate
-(void)KeyBoardVibrate;
//0-9键声音
-(void)KeyBoardNumberSound:(NSInteger)PhoneNumber;
//*键声音
-(void)KeyBoardStarSound;
//#键声音
-(void)KeyBoardPoundSound;
//删除
-(void)KeyBoardCancelSound;
@end

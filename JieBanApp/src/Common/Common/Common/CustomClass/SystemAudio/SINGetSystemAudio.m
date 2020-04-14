//
//  SINGetSystemAudio.m
//  guodiantong
//
//  Created by zhaozhibo on 15/1/27.
//  Copyright (c) 2015年 guodiantong. All rights reserved.
//

#import "SINGetSystemAudio.h"

@interface SINGetSystemAudio(){
    SystemSoundID soundID;
}

@end

static SINGetSystemAudio *mGetSystemAudio = nil;
@implementation SINGetSystemAudio

+(id)shareManager{
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        mGetSystemAudio = [[[self class] alloc] init];
    });
    return mGetSystemAudio;
}
//震动
-(void)KeyBoardVibrate{
    soundID = kSystemSoundID_Vibrate;
    AudioServicesPlaySystemSound(soundID);
}

//0-9按键声音
-(void)KeyBoardNumberSound:(NSInteger)PhoneNumber{

    NSInteger ID =1200+PhoneNumber;
    
    soundID = (int)ID;
   
    AudioServicesPlaySystemSound(soundID);
    
}
//*键声音
-(void)KeyBoardStarSound{
    soundID = 1210;
     AudioServicesPlaySystemSound(soundID);
}
//#键声音
-(void)KeyBoardPoundSound{
    soundID = 1211;
    AudioServicesPlaySystemSound(soundID);
}
//删除
-(void)KeyBoardCancelSound{
    soundID = 1112;
    AudioServicesPlaySystemSound(soundID);
}


@end

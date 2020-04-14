//
//  MergeMessageViewConst.h
//  ECSDKDemo_OC
//
//  Created by 陈长军 on 2017/3/31.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#ifndef MergeMessageViewConst_h
#define MergeMessageViewConst_h


#define EDGE_Distance_LEFT  10

#define EDGE_Distance_RIGHT 15

#define EDGE_Distance_TOP   10

#define EDGE_Distance_BUTTOM   15


#define MERGE_HEAD_WITH   40

#define MERGE_HEAD_HEIGHT 40

#define BUBLEVIEW_TITLE_Disatance 5


#define REFRESH_CELL_IMAGE_LOADFINISH  @"REFRESH_CELL_IMAGE_LOADFINISH"

#define XHMergeBackColor  @"f4f4f4"

//合并消息点击事件
typedef NS_OPTIONS(NSUInteger, XSMergeMessageBublleEvent) {
    XSMergeMessageBublleEvent_Text                                      =1,        //文字
    XSMergeMessageBublleEvent_Image                                     =2,        //图片
    XSMergeMessageBublleEvent_Video                                     =3,         //视频
    XSMergeMessageBublleEvent_File                                      =4,        //文件
    XSMergeMessageBublleEvent_Preview                                   =5,        //链接
    XSMergeMessageBublleEvent_NameCard                                  =6,         //名片
    XSMergeMessageBublleEvent_Voice                                     =7,         //语音
    XSMergeMessageBublleEvent_Location                                     =8,         //位置
};

#endif /* MergeMessageViewConst_h */

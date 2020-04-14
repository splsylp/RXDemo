//
//  DocumentDownLoadView.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/3.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DocumentDownLoadView;

@protocol DocumentDownloadViewDelegate <NSObject>

- (void)DocumentDownloadView:(DocumentDownLoadView*)aView didFailWithError:(NSError *)error;

- (void)DocumentDownloadView_didFinished:(DocumentDownLoadView*)aView;

@end

@interface DocumentDownLoadView : UIView

@property(nonatomic,strong)ECMessage *fileMessage;

@property (nonatomic,strong) UIButton *startBtn;

/** 回调 block */
@property(nonatomic,copy)void (^callBack)(ECError *error);

/**
 * 1、aURLString 文档的URL
 * 2、aType 文档来源类型
 * 3、aDocumentName 文档的名称
 * 4、aDocumentInformation 文档的信息
 */
- (instancetype)initWithFrame:(CGRect)frame
                     filemessage:(ECMessage *)fileMessage;

@property(nonatomic,weak)id<DocumentDownloadViewDelegate>delegate;

-(void)beginLoadFile:(UIButton *)loadBtn;

@end

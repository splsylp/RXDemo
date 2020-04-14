//
//  YMShowImageView.h
//  WFCoretext
//
//  Created by 阿虎 on 14/11/3.
//  Copyright (c) 2014年 tigerwf. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef  void(^didRemoveImage)(void);

@protocol YMShowImageViewDelegate <NSObject>

- (void)deleteImgWith:(NSInteger)index;

@end

@interface YMShowImageView : UIView<UIScrollViewDelegate, UIActionSheetDelegate>
{
    UIImageView *showImage;
}
@property (nonatomic,copy) didRemoveImage removeImg;

@property (nonatomic,assign) id<YMShowImageViewDelegate>delegate;

@property (nonatomic, assign) BOOL isNeedLongPressToSave;

- (void)show:(UIView *)bgView didFinish:(didRemoveImage)tempBlock;

-(id)initWithOtherFrame:(CGRect)frame byClick:(NSInteger)clickTag appendArray:(NSArray *)appendArray isHiddenDeleBtn:(BOOL)isHidden isWatch:(BOOL)isWatch;
-(id)initWithFrame:(CGRect)frame byClick:(NSInteger)clickTag appendArray:(NSArray *)appendArray smallArray:(NSMutableArray *)smallArray isHiddenDeleBtn:(BOOL)isHidden isWatch:(BOOL)isWatch;

@end

//
//  RXSelectContactSectionView.h
//  ECSDKDemo_OC
//
//  Created by zhouwh on 15/8/7.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol selectSectionViewDelegate <NSObject>

- (void)selectSectionView:(NSInteger)index Layer:(NSString *)layer;

@end

@interface RXSelectContactSectionView : UIView{

    NSInteger _sectionTag;
    NSString * _layerTag;
}

@property (nonatomic ,weak) id<selectSectionViewDelegate>delegate;

@property (nonatomic ,strong) UILabel * titleLab;
@property (nonatomic ,strong) UILabel * numLab;
@property (nonatomic ,strong) UIImageView * img;
@property (nonatomic ,strong) NSMutableArray * layerTitleArr;
@property (nonatomic ,strong) UIView * line;

- (instancetype)initWithFrame:(CGRect)frame Tag:(NSInteger)tag Layer:(NSString *)layer;

@end

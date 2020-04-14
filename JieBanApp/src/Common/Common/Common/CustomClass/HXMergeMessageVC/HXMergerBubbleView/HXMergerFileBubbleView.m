//
//  HXMergerFileBubbleView.m
//  ECSDKDemo_OC
//
//  Created by 陈长军 on 2017/4/5.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "HXMergerFileBubbleView.h"
#import "BaseViewController.h"
#import "YXPExtension.h"
//#define KKThemeImage(pathName)  ThemeImage(pathName)
#define KKThemeImage(pathName)  [[AppModel sharedInstance] imageWithName:pathName]

@interface HXMergerFileBubbleView ()


/**
 *@brief 图片
 */
@property (nonatomic, strong) UIImageView *mImageView;


/**
 *@brief 文件名称
 */
@property (nonatomic,strong)  UILabel     *mNameLabel;

/**
 *@brief 文件大小
 */

@property (nonatomic,strong)  UILabel     *mFileSize;


@end


@implementation HXMergerFileBubbleView


- (UILabel *)mFileSize{
    if(!_mFileSize){
        _mFileSize = [[UILabel alloc] initWithFrame:CGRectMake(self.mNameLabel.left, self.mNameLabel.bottom+5, self.width, 14)];
        _mFileSize.textColor = [UIColor grayColor];
        _mFileSize.font = ThemeFontMiddle;
    }
    return _mFileSize;
}

-(UIImageView *)mImageView
{
    if(!_mImageView){
        _mImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, HX_FileImage_Width, HX_FileImage_Width)];
    }
    return _mImageView;
}


- (UILabel *)mNameLabel{
    if(!_mNameLabel){
        _mNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.mImageView.right+10, 10, _model.bubbleW? _model.bubbleW:BubbleViewWidth-(HX_FileImage_Width+10)-15, 0)];
        _mNameLabel.font = ThemeFontMiddle;
        _mNameLabel.textColor = [UIColor blackColor];
        _mNameLabel.textAlignment= NSTextAlignmentLeft;
        _mNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
//        _mNameLabel.numberOfLines = 0;
//        [_mNameLabel sizeToFit];
    }
    return _mNameLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.mNameLabel.width = self.width - (HX_FileImage_Width+10)-15;
}

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(EDGE_Distance_LEFT+MERGE_HEAD_WITH+10, BUBLEVIEW_TITLE_Disatance+EDGE_Distance_TOP+15*FitThemeFont,BubbleViewWidth, HX_FileHeight)];
    if (self) {
        
        [self addSubview:self.mImageView];
        [self addSubview:self.mNameLabel];
        [self addSubview:self.mFileSize];
    
        self.backgroundColor = [UIColor colorWithHexString:@"F3F3F5"];

    }
    return self;
}



-(void)setModel:(HXMergeMessageModel *)model
{
    _model = model;
    
    self.mImageView.image = [self setFileTypeImageViewWithFileExtension:[_model.merge_title pathExtension]];
    self.mNameLabel.text = _model.merge_title;
    
    float totalSize = [model.merge_fileSize floatValue];
    NSString * totalSizeStr = [NSObject dataSizeFormat:[NSString stringWithFormat:@"%f",totalSize]];
    self.mFileSize.text = totalSizeStr;
    
    CGSize size = [_model.merge_title sizeWithFont:ThemeFontMiddle maxSize:CGSizeMake(_model.bubbleW? _model.bubbleW:BubbleViewWidth-(HX_FileImage_Width+10), 400) lineBreakMode:NSLineBreakByWordWrapping];
    self.mNameLabel.height = size.height;
    self.mFileSize.top = self.mNameLabel.bottom + 5;
    
    if(self.mFileSize.bottom >HX_FileImage_Width+10){
        self.height = self.mFileSize.bottom+Buttom_Distance;
    }else{
        self.height = HX_FileImage_Width+10+Buttom_Distance;
    }
    
}

+ (CGFloat)heightForBubbleWithObject:(HXMergeMessageModel *)model
{
    CGFloat height =10+14;
    CGSize size = [model.merge_title sizeWithFont:ThemeFontMiddle maxSize:CGSizeMake(model.bubbleW? model.bubbleW:BubbleViewWidth-(HX_FileImage_Width+10), MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    height  += size.height;
    if(height<HX_FileImage_Width+10){
        height = HX_FileImage_Width+10;
    }
    return height+Buttom_Distance;
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(self.bubbleViewClickBlock){
        self.bubbleViewClickBlock(self.model,XSMergeMessageBublleEvent_File);
    }
}


- (UIImage *)setFileTypeImageViewWithFileExtension:(NSString*)fileExtention{
    
    UIImage *image = nil;
    if ([NSObject isFileType_Doc:fileExtention]) {
        image = KKThemeImage(@"FileTypeS_DOC");
    }
    else if ([NSObject isFileType_PPT:fileExtention]) {
        image = KKThemeImage(@"FileTypeS_PPT");
    }
    else if ([NSObject isFileType_XLS:fileExtention]) {
        image = KKThemeImage(@"FileTypeS_XLS");
    }
    else if ([NSObject isFileType_IMG:fileExtention]) {
        image = KKThemeImage(@"FileTypeS_IMG");
    }
//    else if ([NSObject isFileType_VIDEO:fileExtention]) {
//        image = KKThemeImage(@"FileTypeS_VIDEO");
//    }
//    else if ([NSObject isFileType_AUDIO:fileExtention]) {
//        image = KKThemeImage(@"FileTypeS_AUDIO");
//    }
    else if ([NSObject isFileType_PDF:fileExtention]) {
        image = KKThemeImage(@"FileTypeS_PDF");
    }
    else if ([NSObject isFileType_TXT:fileExtention]) {
        image = KKThemeImage(@"FileTypeS_TXT");
    }
    else if ([NSObject isFileType_ZIP:fileExtention]) {
        image = KKThemeImage(@"FileTypeS_ZIP");
    }
    else{
        image = KKThemeImage(@"FileTypeS_XXX");
    }
    
    return image;
}

@end

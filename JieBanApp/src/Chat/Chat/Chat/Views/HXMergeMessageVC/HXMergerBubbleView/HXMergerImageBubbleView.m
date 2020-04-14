//
//  HXMergerImageBubbleView.m
//  ECSDKDemo_OC
//
//  Created by 陈长军 on 2017/4/1.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "HXMergerImageBubbleView.h"
#import "HXMessageMergeManager.h"



@interface HXMergerImageBubbleView ()<HXLinkLabelDelegate>
@property(nonatomic, strong) NSArray* matches;

@end


@implementation HXMergerImageBubbleView

-(UIImageView *)mImageView
{
    if(!_mImageView){
        _mImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        UIImage* defaultimg = ThemeImage(@"chat_placeholder_image");
        _mImageView.image = defaultimg;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(imageClick:)];
        tap.numberOfTapsRequired = 1; // 单击
       
        [self addGestureRecognizer:tap];
    }
    return _mImageView;
}
-(HXLinkLabel *)mLabel
{
    if(!_mLabel){
        _mLabel = [[HXLinkLabel alloc]initWithFrame:CGRectMake(0,0, kScreenWidth-(EDGE_Distance_LEFT+MERGE_HEAD_WITH+10)-EDGE_Distance_RIGHT, 0)];
        _mLabel.delegate = self;
        //        _label.numberOfLines = 300;
        _mLabel.font = ThemeFontLarge;
        _mLabel.numberOfLines=0;
        _mLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    }
    
    return _mLabel;
}


- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(EDGE_Distance_LEFT+MERGE_HEAD_WITH+10, BUBLEVIEW_TITLE_Disatance+EDGE_Distance_TOP+15*FitThemeFont,BubbleViewWidth, BubbleViewWidth)];
    if (self) {
        [self addSubview:self.mLabel];
        [self addSubview:self.mImageView];
    }
    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    self.mImageView.width = self.width;
}

-(void)setModel:(HXMergeMessageModel *)model{
    NSDictionary *userData = [MessageTypeManager getCusDicWithUserData:model.merge_userData];
    CGFloat gap = 0;
    if ([userData hasValueForKey:@"Rich_text"] || [userData[SMSGTYPE] isEqualToString:@"11"]) { //
        // 图文
        gap = 10;
        DDLogInfo(@"图文");
        _model = model;
        NSString *text = userData[@"content"] ?: userData[@"Rich_text"];
        self.mLabel.text = text.base64DecodingString;
        NSError *error = NULL;
        NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|([a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
        NSRegularExpression *detector = [NSRegularExpression regularExpressionWithPattern:regulaStr options:NSRegularExpressionCaseInsensitive error:&error];
        
        self.matches = [detector matchesInString:self.mLabel.text options:0 range:NSMakeRange(0, self.mLabel.text.length)];
        
        CGSize labelSize = [text.base64DecodingString sizeWithFont:ThemeFontLarge maxSize:CGSizeMake(kScreenWidth -(EDGE_Distance_LEFT + MERGE_HEAD_WITH + 10) -EDGE_Distance_RIGHT, 1000000) lineBreakMode:NSLineBreakByWordWrapping];
        self.mLabel.height = labelSize.height;
        self.height += labelSize.height;
        [self highlightLinksWithIndex:NSNotFound];
        
        
        [self.mLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.mas_offset(0);
            make.height.mas_equalTo(labelSize.height);
        }];
        
//        _model = model;
        NSDictionary *fileDic = [[SendFileData sharedInstance] getCacheFileData:model.merge_url];
        if(fileDic.allKeys.count == 0){
            [[HXMessageMergeManager sharedInstance] startDownload:_model andCompletion:^{
                [[NSNotificationCenter defaultCenter]postNotificationName:REFRESH_CELL_IMAGE_LOADFINISH object:nil];
            }];
        }else{
            //老的存储路径，没有去掉是为了兼容之前的消息记录
            NSString *old_filePath = [HXFileCacheManager DocumentAppDataPath:[fileDic objectForKey:cachefileIdentifer] CacheDirectory:[fileDic objectForKey:cachefileDirectory] dispathName:[fileDic objectForKey:cachefileDisparhName] sessionId:[fileDic objectForKey:cacheimSissionId]];
            
            //新的的存储路径
            NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[fileDic objectForKey:cachefileDisparhName]];
            NSData *imageData = [NSData dataWithContentsOfFile:filePath];
            if (imageData.length<=0) {
                imageData = [NSData dataWithContentsOfFile:old_filePath];
            }
            if(imageData.length>0){
                UIImage *image = [UIImage imageWithData:imageData];
                if (!image) {
                    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fileDic[@"fileUrl"]]]];
                }
                self.mImageView.image = image;
                CGSize imageSize        = image.size;
                self.height             += _model.bubbleW? _model.bubbleW:BubbleViewWidth /(imageSize.width/imageSize.height)+EDGE_Distance_TOP;
//                self.mImageView.height  = BubbleViewWidth /(imageSize.width/imageSize.height);
                self.mImageView.frame = CGRectMake(0, _mLabel.originY+_mLabel.size.height+EDGE_Distance_TOP, self.size.width,_model.bubbleW? _model.bubbleW:BubbleViewWidth /(imageSize.width/imageSize.height ));
            }
                                                   
         }
    }else{
        // 图片
        DDLogInfo(@"图片");
        _model = model;
        
        NSDictionary *fileDic = [[SendFileData sharedInstance] getCacheFileData:model.merge_url];
        if(fileDic.allKeys.count == 0){
            [[HXMessageMergeManager sharedInstance] startDownload:_model andCompletion:^{
                [[NSNotificationCenter defaultCenter]postNotificationName:REFRESH_CELL_IMAGE_LOADFINISH object:nil];
            }];
        }else{
            //老的存储路径，没有去掉是为了兼容之前的消息记录
            NSString *old_filePath = [HXFileCacheManager DocumentAppDataPath:[fileDic objectForKey:cachefileIdentifer] CacheDirectory:[fileDic objectForKey:cachefileDirectory] dispathName:[fileDic objectForKey:cachefileDisparhName] sessionId:[fileDic objectForKey:cacheimSissionId]];
            
            NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[fileDic objectForKey:cachefileDisparhName]];
            
            NSData *imageData = [NSData dataWithContentsOfFile:filePath];
            if (imageData.length<=0) {
                imageData = [NSData dataWithContentsOfFile:old_filePath];
            }
            if(imageData.length>0){
                UIImage *image = [UIImage imageWithData:imageData];
                if (!image) {
                    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fileDic[@"fileUrl"]]]];
                }
                self.mImageView.image = image;
                CGSize imageSize        = image.size;
                self.height             = _model.bubbleW? _model.bubbleW:BubbleViewWidth /(imageSize.width/imageSize.height);
                self.mImageView.height  = self.height;
            }
            
        }
    }
    
//
//    [self.mImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.mas_offset(0);
//        make.top.mas_equalTo(self.mLabel.mas_bottom).mas_offset(gap);
//    }];
  
}


+ (CGFloat)heightForBubbleWithObject:(HXMergeMessageModel *)model{
    CGFloat height = 0;
    NSDictionary *userData =[MessageTypeManager getCusDicWithUserData:model.merge_userData];
    if ([userData hasValueForKey:@"Rich_text"] ||
        [userData[SMSGTYPE] isEqualToString:@"11"]) {// 图文
        DDLogInfo(@"图文");
        NSString *text = [userData hasValueForKey:@"content"] ? userData[@"content"] :userData[@"Rich_text"];
        CGSize size = [text.base64DecodingString sizeWithFont:ThemeFontLarge maxSize:CGSizeMake(kScreenWidth-(EDGE_Distance_LEFT+MERGE_HEAD_WITH+10)-EDGE_Distance_RIGHT, 1000000) lineBreakMode:NSLineBreakByWordWrapping];
        height += size.height;
    }else{
        // 图片
        DDLogInfo(@"图片");
    }
    
    NSDictionary *fileDic = [[SendFileData sharedInstance] getCacheFileData:model.merge_url];
    if(fileDic.allKeys.count == 0){
        height += model.bubbleW?model.bubbleW:BubbleViewWidth;
    }else{
        //老的存储路径，没有去掉是为了兼容之前的消息记录
        NSString *old_filePath = [HXFileCacheManager DocumentAppDataPath:[fileDic objectForKey:cachefileIdentifer] CacheDirectory:[fileDic objectForKey:cachefileDirectory] dispathName:[fileDic objectForKey:cachefileDisparhName] sessionId:[fileDic objectForKey:cacheimSissionId]];
        
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[fileDic objectForKey:cachefileDisparhName]];
        
        NSData *imageData = [NSData dataWithContentsOfFile:filePath];
        if (imageData.length<=0) {
            imageData = [NSData dataWithContentsOfFile:old_filePath];
        }
        
        if(imageData.length>0){
            UIImage *image = [UIImage imageWithData:imageData];
            if (!image) {
                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fileDic[@"fileUrl"]]]];
            }
            CGSize imageSize        = image.size;
            height += model.bubbleW? model.bubbleW:BubbleViewWidth /(imageSize.width/imageSize.height);
        }else{
            height += model.bubbleW? model.bubbleW:BubbleViewWidth;
        }
    }
    return height;
}


- (void)imageClick:(UITapGestureRecognizer *)tap{
    if(self.bubbleViewClickBlock){
        self.bubbleViewClickBlock(self.model,XSMergeMessageBublleEvent_Image);
    }
}
#pragma mark -

- (void)label:(HXLinkLabel *)label didBeginTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:charIndex];
}

- (void)label:(HXLinkLabel *)label didMoveTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:charIndex];
}

- (void)label:(HXLinkLabel *)label didEndTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:NSNotFound];
    
    
    for (NSTextCheckingResult *match in self.matches) {
        
        NSRange matchRange = [match range];
        if ([self isIndex:charIndex inRange:matchRange]) {
            NSString *url = [self.mLabel.text substringWithRange:matchRange];
            self.model.textUrl =url;
            
            if(self.bubbleViewClickBlock){
                self.bubbleViewClickBlock(self.model,XSMergeMessageBublleEvent_Text);
            }
            break;
        }
        
    }
    
    
    
    //    for (NSTextCheckingResult *match in self.matches) {
    //
    //
    //        if ([match resultType] == NSTextCheckingTypeLink) {
    //
    //            NSRange matchRange = [match range];
    //
    //            if ([self isIndex:charIndex inRange:matchRange]) {
    //
    //                self.model.textUrl = match.URL.absoluteString;
    //                if(self.bubbleViewClickBlock){
    //                    self.bubbleViewClickBlock(self.model,XSMergeMessageBublleEvent_Text);
    //                }
    //                break;
    //            }
    //        }
    //    }
    
}

-(void)label:(HXLinkLabel *)label didCancelTouch:(UITouch *)touch {
    
    [self highlightLinksWithIndex:NSNotFound];
}

#pragma mark -

- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range {
    return index > range.location && index < range.location+range.length;
}

- (void)highlightLinksWithIndex:(CFIndex)index {
    
    NSMutableAttributedString* attributedString = [self.mLabel.attributedText mutableCopy];
    
    for (NSTextCheckingResult *match in self.matches) {
        
        //        if ([match resultType] == NSTextCheckingTypeLink) {
        
        NSRange matchRange = [match range];
        
        if ([self isIndex:index inRange:matchRange]) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:matchRange];
        }
        else {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:matchRange];
        }
        
        [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
        //        }
    }
    
    self.mLabel.attributedText = attributedString;
}





@end

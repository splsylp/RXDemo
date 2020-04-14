//
//  HXDocumentImageFileView.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/4.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "HXDocumentImageFileView.h"
#import "YXPEmptyNoticeView.h"
#import "HXFileCacheManager.h"
#import "YXPExtension.h"

@interface HXDocumentImageFileView (){
    BOOL isOpenArray[100];
}

@end

@implementation HXDocumentImageFileView

- (instancetype)initWithFrame:(CGRect)frame selectCacheDocumentType:(SelectCacheDocumentType)aType{
    self = [super initWithFrame:frame];
    if (self) {
        _dataSource = [[NSMutableDictionary alloc] init];
        _selectedAlbumImages = [[NSMutableDictionary alloc] init];
        _selectedCacheImages = [[NSMutableDictionary alloc] init];
        
        for (NSInteger i=0; i<[_dataSource count]; i++) {
            isOpenArray[i] = NO;
        }
        
        _table = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _table.backgroundColor = [UIColor whiteColor];
        _table.backgroundView.backgroundColor = [UIColor whiteColor];
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        _table.delegate = self;
        _table.dataSource = self;
        [self addSubview:_table];
    }
    return self;
}



- (void)loadDataSource{
    [_dataSource removeAllObjects];
    
    [[AlbumManager defaultManager] loadAlbumDirectoryWithFinishedBlock:^(NSArray *Albums) {
        __block NSMutableArray *newArray = [NSMutableArray array];
        for (NSInteger i=0; i<[Albums count]; i++) {
            ALAssetsGroup *group = [Albums objectAtIndex:i];
            [[AlbumManager defaultManager] loadAlbumPhotosWithALAssetsGroupGroup:group finishedBlock:^(NSArray *Assets) {
                [newArray addObjectsFromArray:Assets];
            }];
        }
        if ([newArray count]>0) {
            [_dataSource setObject:newArray forKey:@"Album"];
        }
    
        
        [self loadCacheDataSource];
    }];
}

- (void)loadCacheDataSource{
    NSMutableArray *newArray = [NSMutableArray array];
    
    NSArray * getAllCacheFileData =[[SendFileData sharedInstance]getAppointDirectoryCacheFile:YXP_FileCacheManager_CacheDirectoryOfDocument];
    
    for(NSDictionary *fileDic in getAllCacheFileData)
    {
        
        NSString *Extention =[fileDic objectForKey:cachefileExtension];
        
        if(([NSObject isFileType_IMG:Extention]
            ))
        {
            NSString *filePath = [HXFileCacheManager DocumentAppDataPath:[fileDic objectForKey:cachefileIdentifer] CacheDirectory:[fileDic objectForKey:cachefileDirectory] dispathName:[fileDic objectForKey:cachefileDisparhName] sessionId:[fileDic objectForKey:cacheimSissionId]];
            if(filePath)
            {
                
                [newArray addObject:@{cacheFileLocatPath:filePath,cacheFileInfoKey:fileDic}];
            
            }

        }
        
    }
    
    
    if ([newArray count]>0) {
        [_dataSource setObject:newArray forKey:@"Cache"];
    }
    
    if ([_dataSource count]>0) {
        isOpenArray[0] = YES;
    }
    
    if ([_dataSource count]==0) {
        [YXPEmptyNoticeView showInView:self withImage:KKThemeImage(@"ico_EmptyFile") text:languageStringWithKey(@"该分类没有文件") alignment:KKEmptyNoticeViewAlignment_Top];
    }
    else{
        [YXPEmptyNoticeView hideForView:self];
    }
    [_table reloadData];
}

#pragma mark ==================================================
#pragma mark == UITableViewDataSource
#pragma mark ==================================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isOpenArray[section]==NO) {
        return 0;
    }
    else{
        NSString *key = [_dataSource allKeys].count >section?[[_dataSource allKeys] objectAtIndex:section]:@"";
        NSArray *images = [_dataSource objectForKey:key];
        if ([images count]%4==0) {
            return [images count]/4;
        }
        else{
            return [images count]/4+1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        CGFloat space = 5;
        CGFloat width = ([[UIScreen mainScreen] bounds].size.width - space*5)/4;
        
        UIButton *button01 = [[UIButton alloc] initWithFrame:CGRectMake(space + (space+width)*0, space, width, width)];
        button01.backgroundColor = [UIColor clearColor];
        button01.tag = 1101;
        button01.exclusiveTouch = YES;
        [button01 addTarget:self action:@selector(ButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button01];
        
        UIImageView *selectedImageView01 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(button01.frame)-23-2, CGRectGetMinY(button01.frame)+2, 23, 23)];
        selectedImageView01.backgroundColor = [UIColor clearColor];
        selectedImageView01.tag = 2201;
        selectedImageView01.userInteractionEnabled = NO;
        [cell.contentView addSubview:selectedImageView01];
        
        UIButton *button02 = [[UIButton alloc] initWithFrame:CGRectMake(space + (space+width)*1, space, width, width)];
        button02.backgroundColor = [UIColor clearColor];
        button02.tag = 1102;
        button02.exclusiveTouch = YES;
        [button02 addTarget:self action:@selector(ButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button02];
        
        UIImageView *selectedImageView02 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(button02.frame)-23-2, CGRectGetMinY(button02.frame)+2, 23, 23)];
        selectedImageView02.backgroundColor = [UIColor clearColor];
        selectedImageView02.tag = 2202;
        selectedImageView02.userInteractionEnabled = NO;
        [cell.contentView addSubview:selectedImageView02];
        
        UIButton *button03 = [[UIButton alloc] initWithFrame:CGRectMake(space + (space+width)*2, space, width, width)];
        button03.backgroundColor = [UIColor clearColor];
        button03.tag = 1103;
        button03.exclusiveTouch = YES;
        [button03 addTarget:self action:@selector(ButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button03];
        
        UIImageView *selectedImageView03 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(button03.frame)-23-2, CGRectGetMinY(button03.frame)+2, 23, 23)];
        selectedImageView03.backgroundColor = [UIColor clearColor];
        selectedImageView03.tag = 2203;
        selectedImageView03.userInteractionEnabled = NO;
        [cell.contentView addSubview:selectedImageView03];
        
        
        UIButton *button04 = [[UIButton alloc] initWithFrame:CGRectMake(space + (space+width)*3, space, width, width)];
        button04.backgroundColor = [UIColor clearColor];
        button04.tag = 1104;
        button04.exclusiveTouch = YES;
        [button04 addTarget:self action:@selector(ButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button04];
        UIImageView *selectedImageView04 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(button04.frame)-23-2, CGRectGetMinY(button04.frame)+2, 23, 23)];
        selectedImageView04.backgroundColor = [UIColor clearColor];
        selectedImageView04.tag = 2204;
        selectedImageView04.userInteractionEnabled = NO;
        [cell.contentView addSubview:selectedImageView04];
    }
    
    
    NSString *key = [_dataSource allKeys].count > indexPath.section?[[_dataSource allKeys] objectAtIndex:indexPath.section]:@"";
    NSArray *images = [_dataSource objectForKey:key];
    for (NSInteger i=0; i<4; i++) {
        NSInteger index = indexPath.row*4+i;
        UIButton *button = (UIButton*)[cell.contentView viewWithTag:1101+i];
        UIImageView *selectedImageView = (UIImageView*)[cell.contentView viewWithTag:2201+i];
        
        if ([key isEqualToString:@"Album"]) {
            if (index<[images count]) {
                button.hidden = NO;
                ALAsset *result = [images objectAtIndex:index];
                UIImage* posterImage = [UIImage imageWithCGImage: result.thumbnail];
                [button setBackgroundImage:posterImage forState:UIControlStateNormal];
                /*检查是否选中*/
                [self checkIsSelectedImageView:selectedImageView URL:result.defaultRepresentation.url];
            }
            else{
                button.hidden = YES;
                [self setCellPhotoImage:selectedImageView selectedStatus:2];
            }
        }
        else{
            if (index<[images count]) {
                button.hidden = NO;
                NSDictionary *fileDic = [images objectAtIndex:index];
                NSString *filePath = [fileDic objectForKey:cacheFileLocatPath];
                if(HX_fileEncodedSwitch)
                {
                    
                    [button setBackgroundImage:[UIImage imageWithData:[self decodeFile:[[fileDic objectForKey:cacheFileInfoKey] objectForKey:cachefileKey] withencodedPath:filePath]] forState:UIControlStateNormal];
                }else
                {
                    [button setBackgroundImage:[UIImage imageWithContentsOfFile:filePath] forState:UIControlStateNormal];
                }
                //恒信所有
//                [button setBackgroundImage:[UIImage imageWithContentsOfFile:filePath] forState:UIControlStateNormal];
                /*检查是否选中*/
                if ([_selectedCacheImages objectForKey:filePath]) {
                    [self setCellPhotoImage:selectedImageView selectedStatus:1];
                }
                else{
                    [self setCellPhotoImage:selectedImageView selectedStatus:0];
                }
            }
            else{
                button.hidden = YES;
                [self setCellPhotoImage:selectedImageView selectedStatus:2];
            }
        }
    }
    return cell;
}

//解密处理
- (NSData *)decodeFile:(NSString *)fileKey withencodedPath:(NSString *)encodePath
{
    if(KCNSSTRING_ISEMPTY(fileKey))
    {
        return nil;
    }
    
    NSData *fileData  = [NSData dataWithContentsOfFile:encodePath];
    
    return [NSString decoded_aseData:fileData withKey:fileKey];
    
    //    NSString *base64 = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    //
    //    NSString *decodeStr = [NSString decoded_ase:base64 withKey:fileKey];
    //
    //    NSData *decodeData = [decodeStr dataUsingEncoding:NSUTF8StringEncoding];
    //
    //    return [decodeData initWithBase64EncodedData:decodeData options:0];
    
    
}

- (void)ButtonClicked:(UIButton*)button{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(SelectImageFileView_CanSelected:)]) {
        
        UITableViewCell *cell = nil;
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0 &&[[[UIDevice currentDevice] systemVersion] floatValue]<8.0) {
            cell = (UITableViewCell*)[[button.superview superview] superview];
        }
        else{
            cell = (UITableViewCell*)[button.superview superview];
        }
        
        NSIndexPath *indexPath = [_table indexPathForCell:cell];
        NSInteger index = indexPath.row*4+(button.tag - 1101);
        NSString *key = [_dataSource allKeys].count > indexPath.section?[[_dataSource allKeys] objectAtIndex:indexPath.section]:@"";
        NSArray *images = [_dataSource objectForKey:key];
        if ([key isEqualToString:@"Album"]) {
            ALAsset *result = [images objectAtIndex:index];
            
            NSURL *URL = result.defaultRepresentation.url;
            if ([_selectedAlbumImages objectForKey:[URL absoluteString]]) {
                [_selectedAlbumImages removeObjectForKey:[URL absoluteString]];
                if (self.delegate && [self.delegate respondsToSelector:@selector(SelectImageFileView_SelectedChanged:)]) {
                    [self.delegate SelectImageFileView_SelectedChanged:self];
                }
            }
            else{
                if ([self.delegate SelectImageFileView_CanSelected:self]) {
                    
                    NSMutableDictionary *selectInfo = [NSMutableDictionary dictionary];
                    if (URL) {
                        [selectInfo setObject:URL forKey:AlbumManagerKey_url];
                    }
                    NSString *kName = result.defaultRepresentation.filename;
                    if (! KCNSSTRING_ISEMPTY(kName)) {
                        [selectInfo setObject:kName forKey:AlbumManagerKey_name];
                    }
                    NSDate *kDate = [result valueForProperty:ALAssetPropertyDate];
                    if (kDate && [kDate isKindOfClass:[NSDate class]]) {
                        [selectInfo setObject:kDate forKey:AlbumManagerKey_date];
                    }
                    
                    [selectInfo setObject:[NSString stringWithFormat:@"%lld",result.defaultRepresentation.size] forKey:AlbumManagerKey_size];
                    
                    if (self.WBFlag) [_selectedAlbumImages removeAllObjects];
                    [_selectedAlbumImages setObject:selectInfo forKey:[URL absoluteString]];
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(SelectImageFileView_SelectedChanged:)]) {
                        [self.delegate SelectImageFileView_SelectedChanged:self];
                    }
                }
            }
        }
        else{
            NSDictionary *imageDic = [images objectAtIndex:index];
            NSString *filePath = [imageDic objectForKey:cacheFileLocatPath];
            if ([_selectedCacheImages objectForKey:filePath]) {
                [_selectedCacheImages removeObjectForKey:filePath];
                if (self.delegate && [self.delegate respondsToSelector:@selector(SelectImageFileView_SelectedChanged:)]) {
                    [self.delegate SelectImageFileView_SelectedChanged:self];
                }
            }
            else{
                if ([self.delegate SelectImageFileView_CanSelected:self]) {
                    if (self.WBFlag) [_selectedCacheImages removeAllObjects];
                    [_selectedCacheImages setObject:imageDic forKey:filePath];
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(SelectImageFileView_SelectedChanged:)]) {
                        [self.delegate SelectImageFileView_SelectedChanged:self];
                    }
                }
            }
        }
        
        [self.table reloadData];
    }
}

- (void)checkIsSelectedImageView:(UIImageView*)imageView URL:(NSURL*)URL {
    /*检查是否选中*/
    if ([_selectedAlbumImages objectForKey:[URL absoluteString]]) {
        [self setCellPhotoImage:imageView selectedStatus:1];
    }
    else{
        [self setCellPhotoImage:imageView selectedStatus:0];
    }
}

/**
 设置Cell里面图片选中的状态
 0、未选中状态
 1、选中状态
 2、无状态
 */
- (void)setCellPhotoImage:(UIImageView*)imageView selectedStatus:(NSInteger)status{
    if (status==0) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"KKAlbumPickerController.bundle" ofType:nil];
        NSString *imagePath = [bundlePath stringByAppendingString:@"/KKImagePickerPhoto_UnSelected.png"];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        imageView.image = image;
    }
    else if (status==1){
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"KKAlbumPickerController.bundle" ofType:nil];
        NSString *imagePath = [bundlePath stringByAppendingString:@"/KKImagePickerPhoto_SelectedH.png"];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        imageView.image = image;
    }
    else if (status==2){
        imageView.image = nil;
    }
    else{
        
    }
}


#pragma mark ==================================================
#pragma mark == UITableViewDelegate
#pragma mark ==================================================
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat space = 5;
    CGFloat width = ([[UIScreen mainScreen] bounds].size.width - space*5)/4;
    return space + width;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 49;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 49)];
    button.tag = section + 1100;
    button.exclusiveTouch = YES;
    button.backgroundColor = [UIColor whiteColor];
    button.titleLabel.font = ThemeFontLarge;
    if(isOpenArray[section]){
        [button setImage:KKThemeImage(@"SectionArrow_Down") forState:UIControlStateNormal];
    }
    else{
        [button setImage:KKThemeImage(@"SectionArrow_Right") forState:UIControlStateNormal];
    }
    NSString *key = [_dataSource allKeys].count >section?[[_dataSource allKeys] objectAtIndex:section]:@"";
    if ([key isEqualToString:@"Album"]) {
        [button setTitle:languageStringWithKey(@"相机胶卷" ) forState:UIControlStateNormal];
    }
    else{
        [button setTitle:languageStringWithKey(@"已下载图片") forState:UIControlStateNormal];
    }
    [button setTitleColor:MainTheme_TextBlackColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(headerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 48.5, kScreenWidth, 0.5)];
    line.backgroundColor = MainTheme_CellLineColor;
    [button addSubview:line];
    
    [button setButtonContentAlignment:ButtonContentAlignmentLeft ButtonContentLayoutModal:ButtonContentLayoutModalHorizontal ButtonContentTitlePosition:ButtonContentTitlePositionAfter SapceBetweenImageAndTitle:10 EdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    
    return button;
}

- (void)headerButtonClicked:(UIButton*)button{
    NSInteger index = button.tag - 1100;
    isOpenArray[index] = !isOpenArray[index];
    [_table reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
}

@end

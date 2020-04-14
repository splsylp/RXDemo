//
//  HXDocumentOtherFileView.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/4.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "HXDocumentOtherFileView.h"
#import "YXPEmptyNoticeView.h"
#import "HXFileCacheManager.h"

@implementation HXDocumentOtherFileView

- (instancetype)initWithFrame:(CGRect)frame selectCacheDocumentType:(SelectCacheDocumentType)aType{
    self = [super initWithFrame:frame];
    if (self) {
        _dataSource = [[NSMutableArray alloc] init];
        _selectedDataSource = [[NSMutableDictionary alloc] init];
        
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
    
    
    
    NSArray * getAllCacheFileData =[[SendFileData sharedInstance]getAppointDirectoryCacheFile:YXP_FileCacheManager_CacheDirectoryOfDocument];
    
    for(NSDictionary *fileDic in getAllCacheFileData)
    {
        NSString *Extention =[fileDic objectForKey:cachefileExtension];
        if([Extention isEqualToString:@"mergeMessage"]||[Extention isEqualToString:@"mergemessage"]){
            continue;
        }
        
        if ( [NSObject isFileType_Doc:Extention]   ||
            [NSObject isFileType_PPT:Extention]   ||
            [NSObject isFileType_XLS:Extention]   ||
            [NSObject isFileType_IMG:Extention]   ||
            [NSObject isFileType_VIDEO:Extention] ||
            [NSObject isFileType_AUDIO:Extention] ||
            [NSObject isFileType_PDF:Extention]   ||
            [NSObject isFileType_TXT:Extention])
        {
            continue;
        }else
        {
            
            NSString *filePath = [HXFileCacheManager DocumentAppDataPath:[fileDic objectForKey:cachefileIdentifer] CacheDirectory:[fileDic objectForKey:cachefileDirectory] dispathName:[fileDic objectForKey:cachefileDisparhName] sessionId:[fileDic objectForKey:cacheimSissionId]];
            if(filePath)
            {
                [_dataSource addObject:@{cacheFileLocatPath:filePath,cacheFileInfoKey:fileDic}];
             }

        }
        
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UIImageView *selectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (60-16)/2.0, 16, 16)];
        selectImageView.backgroundColor=[UIColor clearColor];
        selectImageView.tag = 1100;
        selectImageView.image = KKThemeImage(@"Chat_SelectN");
        [cell.contentView addSubview:selectImageView];
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(36, 10, 40, 40)];
        iconImageView.backgroundColor=[UIColor clearColor];
        iconImageView.tag = 1101;
        [cell.contentView addSubview:iconImageView];
        
        UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(86, 10, kScreenWidth-86-10, 20)];
        mainLabel.backgroundColor=[UIColor clearColor];
        mainLabel.font = ThemeFontLarge;
        mainLabel.textColor = MainTheme_TextBlackColor;
        mainLabel.tag = 1102;
        [cell.contentView addSubview:mainLabel];
        
        UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(86, 30, kScreenWidth-86-10, 20)];
        sizeLabel.backgroundColor=[UIColor clearColor];
        sizeLabel.font =ThemeFontSmall;
        sizeLabel.textColor = MainTheme_TextLightGrayColor;
        sizeLabel.tag = 1104;
        sizeLabel.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:sizeLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 59.5, kScreenWidth, 0.5)];
        line.backgroundColor = MainTheme_CellLineColor;
        [cell.contentView addSubview:line];
    }
    
    
    UIImageView *selectImageView = (UIImageView*)[cell.contentView viewWithTag:1100];
    UIImageView *iconImageView = (UIImageView*)[cell.contentView viewWithTag:1101];
    UILabel *mainLabel = (UILabel*)[cell.contentView viewWithTag:1102];
    UILabel *sizeLabel = (UILabel*)[cell.contentView viewWithTag:1104];
    
    NSDictionary *information = [_dataSource objectAtIndex:indexPath.row];
    
    NSDictionary *fileInfoDic =[information objectForKey:cacheFileInfoKey];
    
    
    NSString *fileName =[fileInfoDic objectForKey:cachefileDisparhName];
    
    
    NSString *fileExtention = [fileInfoDic objectForKey:cachefileExtension];
    if ([NSObject isFileType_Doc:fileExtention]) {
        iconImageView.image = KKThemeImage(@"FileTypeS_DOC");
    }
    else if ([NSObject isFileType_PPT:fileExtention]) {
        iconImageView.image = KKThemeImage(@"FileTypeS_PPT");
    }
    else if ([NSObject isFileType_XLS:fileExtention]) {
        iconImageView.image = KKThemeImage(@"FileTypeS_XLS");
    }
    else if ([NSObject isFileType_IMG:fileExtention]) {
        iconImageView.image = KKThemeImage(@"FileTypeS_IMG");
    }
//    else if ([NSObject isFileType_VIDEO:fileExtention]) {
//        iconImageView.image = KKThemeImage(@"FileTypeS_VIDEO");
//    }
//    else if ([NSObject isFileType_AUDIO:fileExtention]) {
//        iconImageView.image = KKThemeImage(@"FileTypeS_AUDIO");
//    }
    else if ([NSObject isFileType_PDF:fileExtention]) {
        iconImageView.image = KKThemeImage(@"FileTypeS_PDF");
    }
    else if ([NSObject isFileType_TXT:fileExtention]) {
        iconImageView.image = KKThemeImage(@"FileTypeS_TXT");
    }
    else if ([NSObject isFileType_ZIP:fileExtention]) {
        iconImageView.image = KKThemeImage(@"FileTypeS_ZIP");
    }
    else{
        iconImageView.image = KKThemeImage(@"FileTypeS_XXX");
    }
    

    mainLabel.text = fileName;
    
    NSTimeInterval fileSize = [fileInfoDic longlongValueForKey:cachefileSize];
    sizeLabel.text = [NSObject dataSizeFormat:[NSString stringWithFormat:@"%f",fileSize]];
    NSString *selectPath = [information objectForKey:cacheFileLocatPath];
    
    if ([_selectedDataSource objectForKey:selectPath]) {
        selectImageView.image = KKThemeImage(@"Chat_SelectH");
    }
    else{
        selectImageView.image = KKThemeImage(@"Chat_SelectN");
    }
    
    return cell;
}

#pragma mark ==================================================
#pragma mark == UITableViewDelegate
#pragma mark ==================================================
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(SelectOtherFileView_CanSelected:)]) {
        
        NSDictionary *information = [_dataSource objectAtIndex:indexPath.row];
        
        NSString *filePath = [information objectForKey:cacheFileLocatPath];
        
        if ([_selectedDataSource objectForKey:filePath]) {
            [_selectedDataSource removeObjectForKey:filePath];
            if (self.delegate && [self.delegate respondsToSelector:@selector(SelectOtherFileView_SelectedChanged:)]) {
                [self.delegate SelectOtherFileView_SelectedChanged:self];
            }
        }
        else{
            if ([self.delegate SelectOtherFileView_CanSelected:self]) {
                [_selectedDataSource setObject:information forKey:filePath];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(SelectOtherFileView_SelectedChanged:)]) {
                    [self.delegate SelectOtherFileView_SelectedChanged:self];
                }
            }
        }
        
        [tableView reloadData];
    }
}
@end

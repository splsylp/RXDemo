//
//  HXDocumentFileView.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/4.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "HXDocumentFileView.h"
#import "YXPEmptyNoticeView.h"
#import "HXFileCacheManager.h"
#import "YXPExtension.h"
@interface HXDocumentFileView (){
    BOOL isOpenArray[100];
}

@end
@implementation HXDocumentFileView

- (instancetype)initWithFrame:(CGRect)frame selectCacheDocumentType:(SelectCacheDocumentType)aType{
    self = [super initWithFrame:frame];
    if (self) {
        _dataSource = [[NSMutableDictionary alloc] init];
        _selectedDataSource = [[NSMutableDictionary alloc] init];
        
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
    
    
//    NSArray *filePathArray = [HXFileCacheManager moreFileListAtDirectory:[HXFileCacheManager getFileCachePath:YXP_FileCacheManager_CacheDirectoryOfDocument]];
    
    NSArray * getAllCacheFileData =[[SendFileData sharedInstance]getAppointDirectoryCacheFile:YXP_FileCacheManager_CacheDirectoryOfDocument];
    
    for(NSDictionary *fileDic in getAllCacheFileData)
    {
        
        NSString *Extention =[fileDic objectForKey:cachefileExtension] ;
        
        if(([NSObject isFileType_Doc:Extention] ||
            [NSObject isFileType_XLS:Extention] ||
            [NSObject isFileType_PPT:Extention] ||
            [NSObject isFileType_PDF:Extention] ||
            [NSObject isFileType_TXT:Extention]
            ))
        {
            NSMutableArray *newArray = [NSMutableArray array];
            NSString *filePath = [HXFileCacheManager DocumentAppDataPath:[fileDic objectForKey:cachefileIdentifer] CacheDirectory:[fileDic objectForKey:cachefileDirectory] dispathName:[fileDic objectForKey:cachefileDisparhName] sessionId:[fileDic objectForKey:cacheimSissionId]];
            if(filePath)
            {
                NSArray *array = [_dataSource objectForKey:[Extention lowercaseString]];
                if (array) {
                    [newArray addObjectsFromArray:array];
                }
                [newArray addObject:@{cacheFileLocatPath:filePath,cacheFileInfoKey:fileDic}];
                [_dataSource removeObjectForKey:[Extention lowercaseString]];
                [_dataSource setObject:newArray forKey:[Extention lowercaseString]];
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isOpenArray[section]) {
        NSString *key = [[_dataSource allKeys] objectAtIndex:section];
        NSArray *array = [_dataSource objectForKey:key];
        return [array count];
    }
    else{
        return 0;
    }
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
        mainLabel.backgroundColor = [UIColor clearColor];
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
    
    NSString *key = [[_dataSource allKeys] objectAtIndex:indexPath.section];
    NSArray *array = [_dataSource objectForKey:key];
    NSDictionary *information = [array objectAtIndex:indexPath.row];
    
    
    NSDictionary *fileInfoDic =[information objectForKey:cacheFileInfoKey];
    
    NSString *fileName = [fileInfoDic objectForKey:cachefileDisparhName];
    NSString *fileExtention =[fileInfoDic objectForKey:cachefileExtension] ;
    
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
    
    NSString *filePath = [information objectForKey:cacheFileLocatPath];
    
    
    NSTimeInterval fileSize = [fileInfoDic longlongValueForKey:@"fileSize"];
    sizeLabel.text = [NSObject dataSizeFormat:[NSString stringWithFormat:@"%f",fileSize]];
    
    if ([_selectedDataSource objectForKey:filePath]) {
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
    return view ;
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
    NSString *key = [[_dataSource allKeys] objectAtIndex:section];
    [button setTitle:[key uppercaseString] forState:UIControlStateNormal];
    [button setTitleColor:MainTheme_TextBlackColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(headerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 48.5, kScreenWidth, 0.5)];
    line.backgroundColor = MainTheme_CellLineColor;
    [button addSubview:line];
    
    [button setButtonContentAlignment:ButtonContentAlignmentLeft ButtonContentLayoutModal:ButtonContentLayoutModalHorizontal ButtonContentTitlePosition:ButtonContentTitlePositionAfter SapceBetweenImageAndTitle:10 EdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    
    return button;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(SelectDocumentFileView_CanSelected:)]) {
        
        NSString *key = [[_dataSource allKeys] objectAtIndex:indexPath.section];
        NSArray *array = [_dataSource objectForKey:key];
        NSDictionary *information = [array objectAtIndex:indexPath.row];
        NSString *filaPath = [information objectForKey:cacheFileLocatPath];
        
        if ([_selectedDataSource objectForKey:filaPath]) {
            [_selectedDataSource removeObjectForKey:filaPath];
            if (self.delegate && [self.delegate respondsToSelector:@selector(SelectDocumentFileView_SelectedChanged:)]) {
                [self.delegate SelectDocumentFileView_SelectedChanged:self];
            }
        }
        else{
            if ([self.delegate SelectDocumentFileView_CanSelected:self]) {
                if (self.WBFlag) [_selectedDataSource removeAllObjects];
                [_selectedDataSource setObject:information forKey:filaPath];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(SelectDocumentFileView_SelectedChanged:)]) {
                    [self.delegate SelectDocumentFileView_SelectedChanged:self];
                }
            }
        }
        
        [tableView reloadData];
    }
}

- (void)headerButtonClicked:(UIButton*)button{
    NSInteger index = button.tag - 1100;
    isOpenArray[index] = !isOpenArray[index];
    [_table reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
}

@end

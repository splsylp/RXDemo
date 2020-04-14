//
//  RXGroupInfoChangeViewController.m
//  ECSDKDemo_OC
//
//  Created by zhouwh on 15/9/12.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "RXGroupInfoChangeViewController.h"

@interface RXGroupInfoChangeViewController ()<UITextViewDelegate>{

    BOOL isGroupName;
    UITextView * _textView;
    UILabel * numberLabel;
    int num;
    BOOL isOwner;//是否是群主
    
}
@property(nonatomic,retain)ECGroup *modifyGroup;//群组信息
@property(nonatomic,retain)NSString *modifyInfoType;//类型
@property(nonatomic,retain)NSString *modifyContent;//修改内容
@property (nonatomic ,retain) NSString *isCanModify;//是否能修改资料
@end

@implementation RXGroupInfoChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *backView =[[UIView alloc]initWithFrame:CGRectMake(0, iOS7?kTotalBarHeight:0, kScreenWidth, kScreenHeight-kTotalBarHeight)];
    backView.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.00f];
    [self.view addSubview:backView];
//    NSDictionary * dataDic = (NSDictionary *)self.data;
//    isGroupName = [[dataDic objectForKey:@"style"] isEqualToString:@"GroupName"];
//    isOwner = [[dataDic objectForKey:@"isOwner"] isEqualToString:@"1"];
    
    if([self.data isKindOfClass:[NSDictionary class]])
    {
        _modifyInfoType =[self.data objectForKey:KGroupInfoModifyType];
        self.modifyGroup =[self.data objectForKey:KGroupInfoModify];
        self.isCanModify = [self.data objectForKey:KGroupInfoModifyJurisdiction];
        if([_modifyInfoType isEqualToString:KGroupInfoGroupName])
        {
            isGroupName=YES;
            _modifyContent=self.modifyGroup.name;
        }else
        {
            isGroupName=NO;
            _modifyContent=self.modifyGroup.declared;
        }
        isOwner =[self.modifyGroup.owner isEqualToString:[[Chat sharedInstance] getAccount]];
    }
    
    num = 0;
    if (isGroupName) {
        self.title = languageStringWithKey(@"群组名称");
        num = 16;
    }else{
        self.title =languageStringWithKey(@"群公告");
        num = 150;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (iOS7) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(2, kTotalBarHeight + 8, kScreenWidth - 4, 200)];
    }else{
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(2, 8, kScreenWidth - 4, 200)];
    }
    
    _textView.text = !KCNSSTRING_ISEMPTY(_modifyContent)?_modifyContent:@"";
    _textView.delegate = self;
    _textView.font = ThemeFontLarge;
    [self.view addSubview:_textView];
    
    numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 160, 170, 150, 30)];
  
    numberLabel.textColor =[UIColor colorWithRed:0.50f green:0.50f blue:0.50f alpha:1.00f];
    if (isEnLocalization) {
        numberLabel.font =ThemeFontSmall;
    }else{
        numberLabel.font = ThemeFontMiddle;
    }
    numberLabel.textAlignment = NSTextAlignmentRight;
    [_textView addSubview:numberLabel];
    
    _textView.editable = NO;
    numberLabel.hidden = YES;
    //add yxp 2017.10.18
    if ([self.isCanModify isEqualToString:@"true"]) {
        
        [self onClickRightBarItem];
    }
    
}

- (void)onClickRightBarItem{
    if (!_textView.editable) {
        _textView.editable = YES;
        numberLabel.hidden = NO;
        [_textView becomeFirstResponder];
        if (num - (int)[_textView.text length] < 0) {
            _textView.text = [_textView.text substringToIndex:16];
        }

         numberLabel.text = [NSString stringWithFormat: @"%@%d%@",languageStringWithKey(@"可输入"),num - (int)[_textView.text length],languageStringWithKey(@"字")];
        [self setBarItemTitle:languageStringWithKey(@"完成") titleColor:APPMainUIColorHexString target:self action:@selector(onClickRightBarItem) type:NavigationBarItemTypeRight];
        return;
    }
   //if([_textField isTextFieldOuttoTenWithWarning:@""])
     if(self.modifyGroup && isGroupName)
    {
        
        if (![_textView.text isGroupNameAvailable]) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",languageStringWithKey(@"含有非法字符")]];
            return;
        }
        
//        if ([_textView.text containsString:@"<"]) {
//            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@:<",languageStringWithKey(@"含有非法字符")]];
//            return;
//        }
//
//        if ([_textView.text containsString:@">"]) {
//            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@:>",languageStringWithKey(@"含有非法字符")]];
//            return;
//        }
        
        
        NSMutableString *groupTitle = [NSMutableString stringWithString:_textView.text];
        if ([groupTitle stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"修改群名称失败")];
            return;
        }
        self.modifyGroup.name=[[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:_textView.text];;
    }else
    {
        if ((_textView.text.length == 0)||(_modifyContent&&[_textView.text isEqualToString:_modifyContent])) {
            [self popViewController];
            return;
        }
       self.modifyGroup.declared=[[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:_textView.text];
    }
    

    typeof(self)strongSelf = self;
    if ([self JudgeTheillegalCharacter:self.modifyContent]) {
        DDLogInfo(@"");
    }
    
    [self showProgressWithMsg:languageStringWithKey(@"正在修改...")];
   
    [[ECDevice sharedInstance].messageManager modifyGroup:self.modifyGroup completion:^(ECError *error, ECGroup *group) {
        [strongSelf closeProgress];
        if (error.errorCode == ECErrorType_NoError) {
            
            /* 在接收修改通知的方法里面进行入库操作 方便区分修改公告和昵称
             [[KitMsgData sharedInstance] addGroupID:group];
             KitGroupInfoData *groupData = [[KitGroupInfoData alloc]init];
             groupData.groupId=group.groupId;
             groupData.declared=group.declared;
             groupData.groupName=group.name;
             groupData.type=group.type;
             groupData.owner=group.owner;
             //             groupData.isAnonymity= group.isAnonymity;
             groupData.memberCount=group.memberCount;
             [KitGroupInfoData insertGroupInfoData:groupData];
             */
            [strongSelf popViewController];
            if (self->isGroupName) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KNotice_reloadSessionGroupName object:group.groupId];
                [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"修改群名称成功")];
            } else {
                [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"修改群公告成功")];
            }
            
            
          } else {
            
            [strongSelf closeProgress];           
              if(error.errorCode==171139)
              {
                  [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"网络不给力")];
                  return ;
              }else if (error.errorCode==590019)
              {
                  [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"含有非法字符")];
                  return ;
              }
              
              if(error.errorDescription)
              {
              
                  [SVProgressHUD showErrorWithStatus:languageStringWithKey(error.errorDescription)];
                  return;
              }
              
              [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"修改失败")];
        }
    }];
   
}
- (BOOL)JudgeTheillegalCharacter:(NSString *)content{
    
    NSString *str =@"^[A-Za-z0-9\\u4e00-\u9fa5]+$";
    
    NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    
    if (![emailTest evaluateWithObject:content]) {
        
        return YES;
        
    }
    
    return NO;
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_textView resignFirstResponder];
}
-(NSString *)subStringWith:(NSString *)string ToIndex:(NSInteger)index{
    
    NSString *result = string;
    if (result.length > index) {
        //Emoji占2个字符，如果是超出了半个Emoji，用15位置来截取会出现Emoji截为2半
        //超出最大长度的那个字符序列(Emoji算一个字符序列)的range
        NSRange rangeIndex = [result rangeOfComposedCharacterSequenceAtIndex:index];
        result = [result substringToIndex:(rangeIndex.location)];
    }
    return result;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    //  群组名称不允许换行
    if (isGroupName && [text isEqualToString:@"\n"]) {
        return NO;
    }
    UITextRange *selectrange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *postion = [textView positionFromPosition:selectrange.start offset:0];
    //没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!postion) {
        NSString * str = [NSString stringWithFormat:@"%@%@",textView.text,text];
        if (str.length > num && text.length > 0) {
            textView.text=[self subStringWith:str ToIndex:num];
            numberLabel.text = [NSString stringWithFormat:@"%@%d%@",languageStringWithKey(@"可输入"),num-(int)textView.text.length,languageStringWithKey(@"字")];
            return NO;
        }else if (str.length >= num && text.length == 0){
            return YES;
        }else{
            return YES;
        }
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
    
    if (textView.text.length == 0) {
        numberLabel.text = [NSString stringWithFormat:@"%@%d%@",languageStringWithKey(@"可输入"),num,languageStringWithKey(@"字")];
    }else{
        UITextRange *selectrange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *postion = [textView positionFromPosition:selectrange.start offset:0];
        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!postion) {
            
            int n = (int)textView.text.length;
            if (n <= num) {
                numberLabel.text = [NSString stringWithFormat:@"%@%d%@",languageStringWithKey(@"可输入"),num - (int)textView.text.length,languageStringWithKey(@"字")];
            }else{
                textView.text=[textView.text substringToIndex:num];
                numberLabel.text = [NSString stringWithFormat:@"%@%d%@",languageStringWithKey(@"可输入"),0,languageStringWithKey(@"字")];
            }
        }
    }
}


//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}



@end

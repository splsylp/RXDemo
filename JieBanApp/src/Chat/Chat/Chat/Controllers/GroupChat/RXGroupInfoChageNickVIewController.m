//
//  RXGroupInfoChageNickVIewController.m
//  Chat
//
//  Created by mac on 2017/3/22.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "RXGroupInfoChageNickVIewController.h"

#define groupJurisdiction  0  //群组权限控制 1 群主权限  0 成员权限

@interface RXGroupInfoChageNickVIewController ()<UITextViewDelegate>{
    
    BOOL isGroupName;
    UITextView * _textView;
    UILabel * numberLabel;
    int num;
    BOOL isOwner;//是否是群主
}
@property(nonatomic,retain)NSString *modifyInfoType;//类型

@property(nonatomic,retain)NSString *modifyContent;//修改内容
@property(nonatomic,strong)ECGroupMember *groupMemberCard;//成员名片


@end

@implementation RXGroupInfoChageNickVIewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.00f];

    if([self.data isKindOfClass:[NSDictionary class]])
    {
        _modifyInfoType =[self.data objectForKey:KGroupInfoModifyType];
//        self.modifyGroup =[self.data objectForKey:KGroupInfoModify];
        if ([_modifyInfoType isEqualToString:kGroupInfoGroupNickName]) {
            self.title = languageStringWithKey(@"群组昵称");
            num = 16;
            [self setGroupMemberInfo:(KitGroupMemberInfoData *)[self.data objectForKey:@"groupMemberCard"]];
            //个人 昵称
            _modifyContent = !KCNSSTRING_ISEMPTY(self.groupMemberCard.display)?self.groupMemberCard.display:[[Common sharedInstance] getUserName];
        }
        isOwner =[[self.data objectForKey:@"isAdminGroup"] boolValue];
    }
#if groupJurisdiction
#else
    isOwner =YES;
    
#endif
    
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
    
    
    numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 160, 170, 150, 30)];
    numberLabel.text = [NSString stringWithFormat:@"%@%lu%@",languageStringWithKey(@"可输入"),([_textView.text length]>num)?0:(num - [_textView.text length]),languageStringWithKey(@"字")];
    numberLabel.textColor =[UIColor colorWithRed:0.50f green:0.50f blue:0.50f alpha:1.00f];
    if (isEnLocalization) {
        numberLabel.font =ThemeFontSmall;
    }else{
        numberLabel.font = ThemeFontMiddle;
    }
    numberLabel.textAlignment = NSTextAlignmentRight;
    [_textView addSubview:numberLabel];
    
    if (isOwner) {
        _textView.editable = YES;
        numberLabel.hidden = NO;

        [self setBarItemTitle:languageStringWithKey(@"完成")  titleColor:APPMainUIColorHexString target:self action:@selector(onClickRightBarItem) type:NavigationBarItemTypeRight];
        [_textView becomeFirstResponder];

    }else{
        _textView.editable = NO;
        numberLabel.hidden = YES;
    }
    
}
- (void)setGroupMemberInfo:(KitGroupMemberInfoData *)groupMemberInfoData {
    
    ECGroupMember * groupMember = [[ECGroupMember alloc] init];
    groupMember.memberId = groupMemberInfoData.memberId;
    groupMember.groupId = groupMemberInfoData.groupId;
    groupMember.display = groupMemberInfoData.memberName;
    groupMember.role = [groupMemberInfoData.role integerValue];
    groupMember.sex = [groupMemberInfoData.sex integerValue];
    groupMember.speakStatus = ECSpeakStatus_Allow;
    self.groupMemberCard = groupMember;
}

- (void)onClickRightBarItem{
    
//    if (!_textView.editable) {
//        _textView.editable = YES;
//        numberLabel.hidden = NO;
//        [_textView becomeFirstResponder];
//        [self setBarRightTitle:@"完成" target:self action:@selector(onClickRightBarItem)];
//        return;
//    }
    
    if (![_modifyInfoType isEqualToString:KGroupInfoGroupDeclared]) {
        
        if (KCNSSTRING_ISEMPTY(_textView.text)) {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"修改内容不能为空")];
            return;
        }
        
    }
    
    if (![_textView.text isGroupNameAvailable]) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",languageStringWithKey(@"含有非法字符")]];
        return;
    }
    
    typeof(self)strongSelf = self;
//    [self showProgressWithMsg:languageStringWithKey(@"正在修改", nil)];
    if ([_modifyInfoType isEqualToString:kGroupInfoGroupNickName]) { //修改自己在群里的昵称
        self.groupMemberCard.display = _textView.text;
        [[ECDevice sharedInstance].messageManager modifyMemberCard:self.groupMemberCard completion:^(ECError *error, ECGroupMember *member) {
            [strongSelf closeProgress];
            if (error.errorCode == ECErrorType_NoError) {
                [KitGlobalClass sharedInstance].isNeedUpdate = YES;
                [KitGroupMemberInfoData insertGroupMemberArray:@[member] withGroupId:member.groupId];
                [strongSelf popViewController];
                [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"修改昵称成功")];
            }else if (error.errorCode == ECErrorType_TypeIsWrong){
                [strongSelf showCustomToast:languageStringWithKey(@"有非法字符")];
            }else {
                
                [strongSelf closeProgress];
                if(error.errorCode ==590019){
//                    [[IMMsgDBAccess sharedInstance]updateMemberStateInGroupId:member.groupId memberState:1];
                    
                    [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"您已不是该群成员")];
                    return ;
                }
                [strongSelf showCustomToast:languageStringWithKey(@"修改群昵称失败")];
                
            }
        }];
    }
    
    
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
    
    if ([text isEqualToString:@"\n"]) {//屏蔽换行
        return NO;
    }
    
    UITextRange *selectedRange = [textView markedTextRange];
    NSString * newText = [textView textInRange:selectedRange];
    if(newText.length>0)
    {
        //DDLogInfo(@"....%@..",newText);
        return YES;
    }
    
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
- (void)textViewDidChange:(UITextView *)textView{
    
    UITextRange *selectedRange = [textView markedTextRange];
    NSString * newText = [textView textInRange:selectedRange];
//    if(newText.length>0)
//    {
//        //DDLogInfo(@"....%@..",newText);
//        return;
//    }
    
    if (textView.text.length == 0) {
        numberLabel.text = [NSString stringWithFormat:@"%@%d%@",languageStringWithKey(@"可输入"),num,languageStringWithKey(@"字")];
    }else{
        int n = (int)textView.text.length;
        if (n <= num) {
            numberLabel.text = [NSString stringWithFormat:@"%@%lu%@",languageStringWithKey(@"可输入"),num - textView.text.length,languageStringWithKey(@"字")];
        }else{
            textView.text=[textView.text substringToIndex:num];
            numberLabel.text = [NSString stringWithFormat:@"%@%d%@",languageStringWithKey(@"可输入"),0,languageStringWithKey(@"字")];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

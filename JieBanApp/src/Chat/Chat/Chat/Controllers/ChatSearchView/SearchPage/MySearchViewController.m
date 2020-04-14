//
//  MySearchViewController.m
//  trrrrasssss
//
//  Created by mac on 2017/4/21.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "MySearchViewController.h"
#import "SearchAllResultPage.h"

@interface MySearchViewController ()

@property(nonatomic,weak)UIView*containerView;



@end

@implementation MySearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIView *contaView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    contaView.center = self.view.center;
    contaView.backgroundColor = [UIColor blueColor];
   
    [self.containerView insertSubview:contaView atIndex:0];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [contaView addGestureRecognizer:tap];
    
    
}
- (instancetype)initWithSearchResultsController:(UIViewController*)searchResultsController

{
    if(self= [super initWithSearchResultsController: searchResultsController]) {
        
        [self setup];
        
    }
    
    return self;
    
}
- (instancetype)init

{
    
    SearchAllResultPage *resultVC = [[SearchAllResultPage   alloc] init];
    
    if(self= [super initWithSearchResultsController:resultVC]) {
    
        [self setup];
    
    }
    
    return self;

}

- (void)setup

{
    
    self.searchBar.placeholder=@"搜索商家";
    
//    [self.searchBarsetSearchFieldBackgroundImage:[UIImagehcq_imageNamed:@"business_search_bg"]forState:UIControlStateNormal];
    
//    [self.searchBarsetImage:[UIImagehcq_imageNamed:@"business_search_icon"]forSearchBarIcon:UISearchBarIconSearchstate:UIControlStateNormal];
    
//    self.searchBar.tintColor=KC_RGB_COLOR(225,225,225);
    
//    self.searchBar.barTintColor=HCQ_VIEW_BACKGROUND_COLOR;
    
    // Get the instance of the UITextField of the search bar
    
    UITextField*searchField = [self.searchBar valueForKey:@"_searchField"];
    
    // Change the search bar placeholder text color
    
    [searchField setValue:self.searchBar.tintColor forKeyPath:@"_placeholderLabel.textColor"];
    
    [[[self.searchBar.subviews.firstObject subviews]firstObject]removeFromSuperview];

    [self.searchBar setValue:@"取消"forKey:@"_cancelButtonText"];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView*)containerView

{
    
    if(!_containerView) {
        
        _containerView=self.view.subviews.firstObject;
        _containerView.backgroundColor = [UIColor greenColor];
        
    }
    
    return _containerView;
    
}


- (void)viewDidLayoutSubviews
{
    
    [super viewDidLayoutSubviews];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    // 修改textfield背景图
    
//    [self.searchBar setSearchFieldBackgroundImage:[UIImagehcq_imageNamed:@"business_search_bg_highlighted"] forState:UIControlStateNormal];
    
}

- (void)viewWillDisappear:(BOOL)animated

{
    
    [super viewWillDisappear:animated];
    
    // 这里再改回来
    
//    [self.searchBar setSearchFieldBackgroundImage:[UIImagehcq_imageNamed:@"business_search_bg"]forState:UIControlStateNormal];
    
}
- (void)dismissKeyboard {
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
   
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

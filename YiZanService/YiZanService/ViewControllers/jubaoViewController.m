//
//  jubaoViewController.m
//  YiZanService
//
//  Created by 密码为空！ on 15/4/24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "jubaoViewController.h"
#import "jubao.h"
@interface jubaoViewController ()
{
    jubao *jubVC;
}
@end

@implementation jubaoViewController
- (void)loadView{
    [super loadView];
    self.mPageName = @"举报";
    self.Title = self.mPageName;
    self.hiddenTabBar = YES;
    [self initView];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager]setEnableAutoToolbar:YES];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
}
- (void)initView{
    
    jubVC = [jubao shareView];

    [self.contentView setFrame:CGRectMake(0, 64,320, 780)];
    
    jubVC.frame = CGRectMake(0, 0, 320, 770);
    [self.contentView addSubview:jubVC];
    
    jubVC.textView.placeholder = @"请输入举报理由";
    
    [jubVC.textView setHolderToTop];
    
    jubVC.jubaoBtn.layer.masksToBounds = YES;
    jubVC.jubaoBtn.layer.cornerRadius = 3;
    
    [jubVC.jubaoBtn addTarget:self action:@selector(jubaoAction:) forControlEvents:UIControlEventTouchUpInside];


}

#pragma mark----举报事件
#warning 举报事件
- (void)jubaoAction:(UIButton *)sender{
    if (jubVC.textView.text == nil || [jubVC.textView.text isEqualToString:@""]) {
        [self showAlertVC:@"提示" alertMsg:@"您未输入任何信息!"];
        return;

    }
    if (jubVC.textView.text.length >= 2000) {
        [self showAlertVC:@"提示" alertMsg:@"内容长度不能超过2000个字符"];
        return;
    }
    else{
        [self showWithStatus:@"正在提交。。。"];
        if( _mtype == 1 )
        {
            SGoods* ssss = SGoods.new;
            ssss.mId = _mId;
            [ssss rePort:jubVC.textView.text block:^(SResBase *resb) {
                if (!resb.msuccess) {
                    [SVProgressHUD showSuccessWithStatus:resb.mmsg];
                    
                    
                }
                else{
                    [SVProgressHUD showErrorWithStatus:resb.mmsg];
                    [self dismiss];
                    [self popViewController];
                }
            }];
        }
        else
        {
            SSeller* ssss = SSeller.new;
            ssss.mId = _mId;
            [ssss rePort:jubVC.textView.text block:^(SResBase *resb) {
                if (!resb.msuccess) {
                    [SVProgressHUD showSuccessWithStatus:resb.mmsg];
                    
                    
                }
                else{
                    [SVProgressHUD showErrorWithStatus:resb.mmsg];
                    [self dismiss];
                    [self popViewController];
                }
            }];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAlertVC:(NSString *)title alertMsg:(NSString *)message{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
    [alert show];
}


@end

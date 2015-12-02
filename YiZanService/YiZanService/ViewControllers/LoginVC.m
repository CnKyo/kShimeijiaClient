//
//  LoginVC.m
//  YiZanService
//
//  Created by ljg on 15-3-20.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "LoginVC.h"
#import "LoginView.h"
#import "RegisterVC.h"
#import "WebVC.h"
@interface LoginVC ()<UITextFieldDelegate>
{
    LoginView *loginView;
}
@end

@implementation LoginVC
-(void)loadView
{
    self.hiddenTabBar = YES;
    [super loadView];
//    self.hiddenBackBtn = YES;
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
    self.Title =@"登录";
    // Do any additional setup after loading the view.
    self.mPageName = @"登录";
    CGRect rect = self.view.frame;
    rect.origin.y +=100;
    self.view.frame = rect;
    self.rightBtnTitle = @"注册";
    loginView = (LoginView*)[[[NSBundle mainBundle]loadNibNamed:@"LoginVC" owner:self options:nil]objectAtIndex:0];
    loginView.phoneView.layer.masksToBounds = YES;
    loginView.phoneView.layer.cornerRadius = 3;
    loginView.passView.layer.masksToBounds = YES;
    loginView.passView.layer.cornerRadius = 3;
    loginView.loginBtn.layer.masksToBounds = YES;
    loginView.loginBtn.layer.cornerRadius = 3;
    [self.contentView addSubview:loginView];
    [loginView.loginBtn addTarget:self action:@selector(loginBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [loginView.forgetBtn addTarget:self action:@selector(forgetBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [loginView.announce addTarget:self action:@selector(announceBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    loginView.inputphone.delegate = self;
    loginView.inputpasswd.delegate = self;
//    [self.contentView addSubview:self.view];


}


-(void)rightBtnTouched:(id)sender
{
    RegisterVC *vc = [[RegisterVC alloc]init];
    vc.tagVC = self.tagVC;
    vc.comFrom = 1;
    [self pushViewController:vc];
}
-(void)loginBtnTouched:(id)sender
{
    if (![GInfo shareClient]) {
//        [self addNotifacationStatus:@"获取配置信息失败,请稍后再试"];
        [loginView.inputphone resignFirstResponder];
        [loginView.inputpasswd resignFirstResponder];
        MLLog(@"获取配置信息失败,请稍后再试");
        return;
    }
    else if (![Util isMobileNumber:loginView.inputphone.text]) {
        [self showErrorStatus:@"请输入合法的手机号码"];
        [loginView.inputphone becomeFirstResponder];
        return;
    }
    else if (![Util checkPasswdPre:loginView.inputpasswd.text]) {
        [self showErrorStatus:@"请输入6-20位密码"];
        [loginView.inputpasswd becomeFirstResponder];
        return;
    }
    else
    {
        [SVProgressHUD showWithStatus:@"正在登录..." maskType:SVProgressHUDMaskTypeClear];
        [SUser loginWithPhone:loginView.inputphone.text psw:loginView.inputpasswd.text block:^(SResBase *resb, SUser *user) {
            if (resb.msuccess) {
                [SVProgressHUD dismiss];
                [self logOK];
            }
            else
            {
                [self showErrorStatus:resb.mmsg];
            }
        }];
    }
}
-(void)logOK
{

    if( self.tagVC )
    {
        NSMutableArray* t = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
        [t removeLastObject];
        [t addObject:self.tagVC];
        [self.navigationController setViewControllers:t animated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }

   // [APService setAlias:[Qu_UserInfo currentUser].q_username callbackSelector:nil object:nil];
    
}


#define TEXT_MAXLENGTH 11
#define PASS_LENGHT 20
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *new = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSInteger res;
    if (textField.tag==14) {
        res= PASS_LENGHT-[new length];


    }else
    {
        res= TEXT_MAXLENGTH-[new length];

    }
    if(res >= 0){
        return YES;
    }
    else{
        NSRange rg = {0,[string length]+res};
        if (rg.length>0) {
            NSString *s = [string substringWithRange:rg];
            [textField setText:[textField.text stringByReplacingCharactersInRange:range withString:s]];
        }
        return NO;
    }
    
}
-(void)forgetBtnTouched:(id)sender
{
    RegisterVC *vc = [[RegisterVC alloc]init];
    vc.tagVC = self.tagVC;
    vc.comFrom = 2;
    [self pushViewController:vc];
}
-(void)announceBtnTouched:(id)sender
{
    WebVC* vc = [[WebVC alloc]init];
    vc.mName = @"免责声明";
    vc.mUrl = @"http://wap.shimeijiavip.com/More/disclaimer";
    [self pushViewController:vc];
    
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

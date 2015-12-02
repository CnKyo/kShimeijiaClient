//
//  MyselfVC.m
//  YiZanService
//
//  Created by ljg on 15-3-20.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "MyselfVC.h"
#import "MyselfView.h"
#import "MyselfDetailVC.h"
#import "CouponVC.h"
#import "MyCollectionVC.h"
#import "AddressVC.h"

#import "MyMessage.h"

#import "messageView.h"
@interface MyselfVC ()<UIGestureRecognizerDelegate>
{
    MyselfView *view;
    MyMessage *MyMessageVC;
}
@end

@implementation MyselfVC
{
    BOOL _bgotologin;
}
-(void)loadView
{
    [super loadView];
    self.hiddenTabBar = NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    if ([SUser isNeedLogin]) {
        view.userName.hidden = YES;
        view.userphone.hidden = YES;
        view.needLogin.hidden = NO;

        view.userhead.image = [UIImage imageNamed:@"defultHead"];
    }
    else
    {
        view.userName.hidden = NO;
        view.userphone.hidden = NO;
        view.needLogin.hidden = YES;

        view.userName.text = [SUser currentUser].mUserName;
        view.userphone.text = [SUser currentUser].mPhone;

        [view.userhead sd_setImageWithURL:[NSURL URLWithString:[SUser currentUser].mHeadImgURL] placeholderImage:[UIImage imageNamed:@"defultHead.png"]];
        
        [self initMessageView];

    }
    [self loadData];

}
- (void)loadData{
    
    [[SUser currentUser] getUserState:^(SResBase *resb, SUserState *userstate) {

        MyMessageVC.BadgeBtn.hidden = !userstate.mbHaveNewMsg;

    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.Title = @"我的";
    self.mPageName = self.Title;
    self.hiddenBackBtn = YES;
    view = [[[NSBundle mainBundle]loadNibNamed:@"MyselfView" owner:self options:nil]objectAtIndex:0];
   // return view;
    [view.loginBtn addTarget:self action:@selector(loginBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    view.userhead.layer.masksToBounds = YES;
    view.userhead.layer.cornerRadius = 32;
    [self.contentView addSubview:view];
    [view.youhuiquanBtn addTarget:self action:@selector(CouponBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [view.shoucangBtn addTarget:self action:@selector(CollectionBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [view.dizhiBtn addTarget:self action:@selector(AddressBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if( self.navigationController.viewControllers.count == 1 )  return NO;
    return YES;
}
- (void)initMessageView{
    
    MyMessageVC = [MyMessage shareView];
    MyMessageVC.frame = CGRectMake(0, 259, 320, 51);
    
    [MyMessageVC.MyMessageBtn addTarget:self action:@selector(MessageBrnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    MyMessageVC.BadgeBtn.layer.masksToBounds = YES;
    MyMessageVC.BadgeBtn.layer.cornerRadius = 13;

    [SMessage getMsgList:self.page block:^(SResBase *resb, NSArray *all) {
        if (resb.msuccess) {
            [self.tempArray removeAllObjects];

            [self.tempArray addObjectsFromArray:all];
            [MyMessageVC.BadgeBtn setTitle:[NSString stringWithFormat:@"%lu",all.count] forState:UIControlStateNormal];
            MLLog(@"取出来的数组有：%lu",(unsigned long)self.tempArray.count);

            [SVProgressHUD dismiss];
            
        }
        else{
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        
        if( self.tempArray.count == 0 )
        {
            [self addEmptyViewWithImg:nil];
        }
        else
        {
            [self removeEmptyView];
        }

    }];
    
//    if (self.tempArray.count == 0) {
//        
        MyMessageVC.BadgeBtn.hidden = YES;
//    }
    [self.contentView addSubview:MyMessageVC];
}
#pragma mark-+-+-+-消息页面事件
- (void)MessageBrnAction:(UIButton *)sender{
    messageView *msgVC = [[messageView alloc] init];
    [MyMessageVC.BadgeBtn setHidden:YES];
    [self pushViewController:msgVC];
}
-(void)CouponBtnTouched:(id)sender
{
    CouponVC *vc = [[CouponVC alloc]init];
    [self pushViewController:vc];
}
-(void)CollectionBtnTouched:(id)sender
{
    MyCollectionVC *vc = [[MyCollectionVC alloc]init];
    [self pushViewController:vc];
}
-(void)AddressBtnTouched:(id)sender
{
    AddressVC *vc = [[AddressVC alloc]init];
    [self pushViewController:vc];

}
-(void)loginBtnTouched:(id)sender
{
    MyselfDetailVC *vc = [[MyselfDetailVC alloc]initWithNibName:@"MyselfDetailVC" bundle:nil];
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

//
//  OrderDetailVC.m
//  YiZanService
//
//  Created by ljg on 15-3-26.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "OrderDetailVC.h"
#import "OrderDetailView.h"
#import "WaiterDetailVC.h"

#import "ServicerChoiceView.h"
@interface OrderDetailVC ()

@end

@implementation OrderDetailVC
{
    OrderDetailView *view;
}
-(void)loadView
{
    self.hiddenTabBar = YES;
    [super loadView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.Title = @"订单详情";
    self.mPageName = self.Title;

    ///判断是否是个人活着机构
    if ( ![self.tempOrder bshowGroup] ) {
        [self initRenyuan];

    }else{
        [self initJigou];

    }
}
#pragma mark---加载服务人员
- (void)initRenyuan{
    view = [OrderDetailView shareView];
    [self.contentView addSubview:view];
    [SVProgressHUD showWithStatus:@"获取中"];
    [self.tempOrder getDetail:^(SResBase *retobj) {
        if (retobj.msuccess) {
            [SVProgressHUD dismiss];
            view.states.text = self.tempOrder.mOrderStateStr;
            view.phone.text = self.tempOrder.mPhoneNum;
            view.ordernum.text = self.tempOrder.mSn;
            view.ordertime.text = self.tempOrder.mApptime;
            view.address.text = self.tempOrder.mAddress;
            view.waitername.text = self.tempOrder.mStaff.mName;
            
            view.headimg.layer.masksToBounds = YES;
            view.headimg.layer.cornerRadius = 3;
            [view.headimg sd_setImageWithURL:[NSURL URLWithString:self.tempOrder.mGooods.mImgURL] placeholderImage:DefatultHead];
            
            
            view.serviceName.text = self.tempOrder.mGooods.mName;
            view.serviceprice.text = [NSString stringWithFormat:@"¥%.2f",self.tempOrder.mGooods.mPrice];
            [view.callbtn addTarget:self action:@selector(callTel:) forControlEvents:UIControlEventTouchUpInside];
            [view.callbtn setTitle:[NSString stringWithFormat:@"点击拨打客服电话:%@",[GInfo shareClient].mServiceTel] forState:UIControlStateNormal];
            if (self.tempOrder.mPromMoney==0) {
                view.coupon.text = @"未使用优惠券";
                view.totalprice.text = [NSString stringWithFormat:@"¥%.2f",self.tempOrder.mTotalMoney];
            }
            else
            {
                view.coupon.text = self.tempOrder.mPromStr;
                float ttt =self.tempOrder.mTotalMoney -self.tempOrder.mPromMoney;
                if( ttt < 0.0f )
                    ttt = 0.00f;
                view.totalprice.text = [NSString stringWithFormat:@"¥%.2f",ttt];
            }
            
            
            
        }else
        {
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
            [self popViewController];
        }
    }];
    [view.checkwaiterDetailBtn addTarget:self action:@selector(checkwaiterDetailBtn) forControlEvents:UIControlEventTouchUpInside];
    self.contentView.contentSize = CGSizeMake(320, view.frame.size.height);
}
#pragma mark---加载服务机构
- (void)initJigou{

    view = [OrderDetailView shareViewTwo];
    [self.contentView addSubview:view];
    [SVProgressHUD showWithStatus:@"获取中"];
    [self.tempOrder getDetail:^(SResBase *retobj) {
        if (retobj.msuccess) {
            [SVProgressHUD dismiss];
            view.states.text = self.tempOrder.mOrderStateStr;
            view.phone.text = self.tempOrder.mPhoneNum;
            view.ordernum.text = self.tempOrder.mSn;
            view.ordertime.text = self.tempOrder.mApptime;
            view.address.text = self.tempOrder.mAddress;
            view.waitername.text = self.tempOrder.mStaff.mName;
            view.FuwuRenyuanLb.text = self.tempOrder.mStaff.mName;
            view.FuwuJigouLb.text = self.tempOrder.mSeller.mName;
            view.headimg.layer.masksToBounds = YES;
            view.headimg.layer.cornerRadius = 3;
            [view.headimg sd_setImageWithURL:[NSURL URLWithString:self.tempOrder.mGooods.mImgURL] placeholderImage:DefatultHead];
            
            
            view.serviceName.text = self.tempOrder.mGooods.mName;
            view.serviceprice.text = [NSString stringWithFormat:@"¥%.2f",self.tempOrder.mGooods.mPrice];
            [view.callbtn addTarget:self action:@selector(callTel:) forControlEvents:UIControlEventTouchUpInside];
            [view.callbtn setTitle:[NSString stringWithFormat:@"点击拨打客服电话:%@",[GInfo shareClient].mServiceTel] forState:UIControlStateNormal];
            if (self.tempOrder.mPromMoney==0) {
                view.coupon.text = @"未使用优惠券";
                view.totalprice.text = [NSString stringWithFormat:@"¥%.2f",self.tempOrder.mTotalMoney];
            }
            else
            {
                view.coupon.text = self.tempOrder.mPromStr;
                float ttt =self.tempOrder.mTotalMoney -self.tempOrder.mPromMoney;
                if( ttt < 0.0f )
                    ttt = 0.00f;
                view.totalprice.text = [NSString stringWithFormat:@"¥%.2f",ttt];
            }
            
            
            
        }else
        {
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
            [self popViewController];
        }
    }];
    [view.checkwaiterDetailBtn addTarget:self action:@selector(jigouAction:) forControlEvents:UIControlEventTouchUpInside];
    self.contentView.contentSize = CGSizeMake(320, view.frame.size.height);

}
- (void)jigouAction:(UIButton *)sender{
    ServicerChoiceView *sVC = [[ServicerChoiceView alloc]init];
    sVC.mSellerid = self.tempOrder.mSeller.mId;
    [self pushViewController:sVC];
    
}
-(void)callTel:(UIButton*)sender
{
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",[GInfo shareClient].mServiceTel];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
-(void)checkwaiterDetailBtn
{
    WaiterDetailVC *vc = [[WaiterDetailVC alloc]init];
    vc.sellerStaff = self.tempOrder.mStaff;
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

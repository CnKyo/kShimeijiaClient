//
//  OrderVC.m
//  YiZanService
//
//  Created by ljg on 15-3-20.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "OrderVC.h"
#import "OrderCell.h"
#import "OrderDetailVC.h"
#import "OrderPayVC.h"
#import "PingjiaVC.h"
#import "WaiterDetailVC.h"
#import "UILabel+myLabel.h"


#import "ServicerChoiceView.h"
@interface OrderVC ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
{
    UIButton *tempBtn;
    UIImageView *lineImage;
    int nowSelect;
    NSMutableDictionary *tempDic;
    
    BOOL    _bgotologin;

}
@end

@implementation OrderVC
{
    NSInteger _mybereloadone;
    
    BOOL      _neverload;
}
-(void)loadView
{
    [super loadView];
    self.hiddenTabBar = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( [SUser isNeedLogin] ) {

        if( !_bgotologin )
        {
            _bgotologin = YES;
            [self gotoLoginVC];
        }
        else
        {
            _bgotologin = NO;
        }
        return;
    }
    
    if( _neverload )
    {
        _neverload = NO;
        [self.tableView headerBeginRefreshing];
    }
    
    if( _mybereloadone != -1 )
    {

        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_mybereloadone inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        _mybereloadone = -1;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.Title = @"订单";
    self.mPageName = self.Title;
    _mybereloadone = -1;
    tempDic = [[NSMutableDictionary alloc]init];
    self.hiddenBackBtn = YES;

    [self loadTableView:CGRectMake(0, 45, 320, DEVICE_InNavTabBar_Height-45) delegate:self dataSource:self];
    [self loadTopView];
    self.haveHeader = YES;
    self.haveFooter = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];

    
    UINib *nib = [UINib nibWithNibName:@"OrderCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
    UINib *nib1 = [UINib nibWithNibName:@"JigouCell" bundle:nil];
    [self.tableView registerNib:nib1 forCellReuseIdentifier:@"cell1"];

    
    
    if( [SUser currentUser] )
        [self.tableView headerBeginRefreshing];
    else
        _neverload = YES;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if( self.navigationController.viewControllers.count == 1 )  return NO;
    return YES;
}
-(void)headerBeganRefresh
{
    self.page = 1;


    if ( [SUser isNeedLogin] ) {
        
        if( !_bgotologin )
        {
            _bgotologin = YES;
            [SVProgressHUD showErrorWithStatus:@"你还未登录"];

            [self gotoLoginVC];
        }
        else
        {
            _bgotologin = NO;
        }
        [self headerEndRefresh];

        return;
    }


    [[SUser currentUser]getMyOrders:nowSelect page:(int)self.page block:^(SResBase *resb, NSArray *all) {
        [self headerEndRefresh];

        if (resb.msuccess) {
            NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];

            if (all.count!=0) {
                [self removeEmptyView];
                
                [tempDic setObject:all forKey:key2];
            }else
            {
                [tempDic setObject:[NSArray array]  forKey:key2];
                //  [SVProgressHUD showErrorWithStatus:@"暂无数据"];
                [self addEmptyView:@"暂无数据"];
            }
            
            
            [self.tableView reloadData];

        }else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
            [self addEmptyView:resb.mmsg];
        }
        
    }];

}
-(void)footetBeganRefresh
{
    
    if ( [SUser isNeedLogin] ) {
        
        if( !_bgotologin )
        {
            _bgotologin = YES;
            [SVProgressHUD showErrorWithStatus:@"你还未登录"];

            [self gotoLoginVC];
        }
        else
        {
            _bgotologin = NO;
        }
        [self footetEndRefresh];
        return;
    }
    
    self.page ++;
    
    [[SUser currentUser]getMyOrders:nowSelect page:(int)self.page block:^(SResBase *resb, NSArray *all) {
        [self footetEndRefresh];

        if (resb.msuccess) {
            NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];

            NSArray *oldarr = [tempDic objectForKey:key2];

            if (all.count!=0) {
                [self removeEmptyView];
               

                NSMutableArray *array = [NSMutableArray array];
                if (oldarr) {
                    [array addObjectsFromArray:oldarr];
                }
                [array addObjectsFromArray:all];
                [tempDic setObject:array forKey:key2];
            }else
            {
                if(!oldarr||oldarr.count==0)
                {
                    [SVProgressHUD showSuccessWithStatus:@"暂无数据"];
                }
                else
                    [SVProgressHUD showSuccessWithStatus:@"暂无新数据"];
                //   [self addEmptyView:@"暂无数据"];

            }
            [self.tableView reloadData];

        }else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
            // [self addEmptyView:resb.mmsg];
        }
    }];

}
-(void)loadTopView
{
    UIView *topView  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    topView.backgroundColor = [UIColor whiteColor];
    float x = 0;
    for (int i =0; i<3; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, 106, 45)];
        [btn setTitle:@"全部" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitleColor:COLOR(242, 95, 145) forState:UIControlStateNormal];
        [topView addSubview:btn];
        if (i==0) {
            tempBtn = btn;
            lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 70, 3)];
            lineImage.backgroundColor = COLOR(242, 95, 145);
            lineImage.center = btn.center;
            CGRect rect = lineImage.frame;
            rect.origin.y = 42;
            lineImage.frame = rect;
            [topView addSubview:lineImage];
            nowSelect = 1;
        }
        else if(i == 1)
        {
            [btn setTitle:@"进行中" forState:UIControlStateNormal];
            [btn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];

        }
        else
        {
            [btn setTitle:@"待评价" forState:UIControlStateNormal];
            [btn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];
            // paixuImage.backgroundColor = [UIColor redColor];

        }
        btn.tag = 10+i;
        [btn addTarget:self action:@selector(topbtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        x+=106;
    }

    UIImageView *xianimg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 44, 320, 1)];
    xianimg.backgroundColor  = COLOR(232, 232, 232);
    [topView addSubview:xianimg];
    [self.contentView addSubview:topView];
}
-(void)topbtnTouched:(UIButton *)sender
{
    if (tempBtn == sender&&sender.tag !=12) {
        return;
    }
    else
    {
        if (sender.tag ==10) {
            NSLog(@"left");
            nowSelect = 1;
        }
        else if(sender.tag == 11)
        {
            nowSelect = 2;
            NSLog(@"mid");
        }
        else
        {
            nowSelect = 3;
            NSLog(@"right");

        }
        NSString *key1 = [NSString stringWithFormat:@"nowselectpage%d",nowSelect];

        if (![tempDic objectForKey:key1]) {
            [self.tableView headerBeginRefreshing];
        }
        else
        {
            [self removeEmptyView];
            [self.tableView reloadData];
        }

        [tempBtn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];
        [sender setTitleColor:COLOR(242, 95, 145) forState:UIControlStateNormal];
        tempBtn = sender;
      //  lineImage.center = sender.center;
        CGRect rect = lineImage.frame;
        rect.origin.y = 42;
        float x = sender.center.x;
        [UIView animateWithDuration:0.2 animations:^{
            CGRect arect = lineImage.frame ;
            arect.origin.x = x-lineImage.frame.size.width/2;
            lineImage.frame = arect;
        }];
        
    }
}
#pragma mark -- tableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    return arr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 215;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];

    SOrder *order = [arr objectAtIndex:indexPath.row];


     ///判断是否是个人活着机构
    if ( ![order bshowGroup] ) {
        
        
        OrderCell *cell = (OrderCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (arr.count == 0) {
            return cell;
        }
        if (arr.count == 0) {
            return cell;
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        
        cell.waiterName.text = order.mSeller.mName;
        CGFloat sss = [cell.waiterName.text sizeWithFont:cell.waiterName.font constrainedToSize:CGSizeMake(MAXFLOAT, cell.waiterName.frame.size.height)].width;
        
        CGRect rrr = cell.waiterName.frame;
        rrr.size.width = sss;
        cell.waiterName.frame = rrr;
        [Util relPosUI:cell.waiterName dif:25.0f tag:cell.jiantou tagatdic:E_dic_r];
        [cell.renyuanBtn addTarget:self action:@selector(choiceRenyuan:) forControlEvents:UIControlEventTouchUpInside];
        cell.states.text = order.mOrderStateStr;
        cell.serviceName.text = order.mGooods.mName;
        cell.ServiceNameLb.text = order.mStaff.mName;
        cell.PriceLb.text = [NSString stringWithFormat:@"¥%.2f",order.mPayMoney];
        cell.ordertime.text = order.mApptime;
        cell.address.text = order.mAddress;
        [cell.JigouBtn addTarget:self action:@selector(jigouAction:) forControlEvents:UIControlEventTouchUpInside];
        if (order.mPromMoney==0) {
            cell.fujia.hidden = YES;
            cell.youhui.hidden = YES;
        }
        else
        {
            cell.youhui.hidden = NO;
            cell.fujia.hidden = NO;
        }
        
        cell.fujia.text = [NSString stringWithFormat:@"¥%.2f",order.mPromMoney];
        cell.total.text =[NSString stringWithFormat:@"¥%.2f",order.mTotalMoney];
        [cell.headimg sd_setImageWithURL:[NSURL URLWithString:order.mGooods.mImgURL] placeholderImage:[UIImage imageNamed:@"14.png"]];
        cell.headimg.layer.masksToBounds = YES;
        cell.headimg.layer.cornerRadius = 5;
        
        switch ( [order getUIShowbt]) {
            case E_UIShow_NON:
            {
                cell.cancleBtn.hidden = YES;
                cell.payBtn.hidden = YES;
                cell.replyBtn.hidden = YES;
                cell.anyBtn.hidden = YES;
                cell.kefu.hidden = YES;
                
            }
                break;
            case E_UIShow_Cancle_Pay:
            {
                cell.cancleBtn.hidden = NO;
                cell.payBtn.hidden = NO;
                cell.replyBtn.hidden = YES;
                cell.anyBtn.hidden = YES;
                cell.kefu.hidden = YES;
                
            }
                break;
            case E_UIShow_Cancle_ConTa:
            {
                cell.cancleBtn.hidden = NO;
                cell.payBtn.hidden = YES;
                cell.replyBtn.hidden = YES;
                cell.anyBtn.hidden = NO;
                cell.kefu.hidden = YES;
                [cell.anyBtn setTitle:@"联系TA" forState:UIControlStateNormal];
            }
                break;
            case E_UIShow_ConTa_ConKf:
            {
                cell.cancleBtn.hidden = YES;
                cell.payBtn.hidden = YES;
                cell.replyBtn.hidden = YES;
                cell.anyBtn.hidden = NO;
                cell.kefu.hidden = NO;
                [cell.anyBtn setTitle:@"联系TA" forState:UIControlStateNormal];
                
            }
                break;
            case E_UIShow_ConKf:
            {//修改
                cell.cancleBtn.hidden = YES;
                cell.payBtn.hidden = YES;
                cell.replyBtn.hidden = YES;
                cell.anyBtn.hidden = NO;//客服
                cell.kefu.hidden = YES;
                [cell.anyBtn setTitle:@"联系客服" forState:UIControlStateNormal];
                
            }
                break;
            case E_UIShow_Confim:
            {
                cell.cancleBtn.hidden = YES;
                cell.payBtn.hidden = YES;
                cell.replyBtn.hidden = YES;
                cell.anyBtn.hidden = NO;
                cell.kefu.hidden = YES;
                [cell.anyBtn setTitle:@"确认完成" forState:UIControlStateNormal];
                
            }
                break;
            case E_UIShow_Comment:
            {
                cell.cancleBtn.hidden = YES;
                cell.payBtn.hidden = YES;
                cell.replyBtn.hidden = NO;
                cell.anyBtn.hidden = YES;
                cell.kefu.hidden = YES;
                
            }
                break;
            case E_UIShow_Del:
            {
                cell.cancleBtn.hidden = YES;
                cell.payBtn.hidden = YES;
                cell.replyBtn.hidden = YES;
                cell.anyBtn.hidden = NO;
                cell.kefu.hidden = YES;
                [cell.anyBtn setTitle:@"删除订单" forState:UIControlStateNormal];
                
            }
                break;
            case E_UIShow_Del_ConKf:
            {
                cell.cancleBtn.hidden = YES;
                cell.payBtn.hidden = YES;
                cell.replyBtn.hidden = YES;
                cell.anyBtn.hidden = NO;
                cell.kefu.hidden = NO;
                [cell.anyBtn setTitle:@"删除订单" forState:UIControlStateNormal];
                
            }
                break;
                
                
            default:
                break;
        }
        [cell.cancleBtn addTarget:self action:@selector(btnTouched:) forControlEvents:UIControlEventTouchUpInside];
        [cell.payBtn addTarget:self action:@selector(btnTouched:) forControlEvents:UIControlEventTouchUpInside];
        [cell.replyBtn addTarget:self action:@selector(btnTouched:) forControlEvents:UIControlEventTouchUpInside];
        [cell.anyBtn addTarget:self action:@selector(btnTouched:) forControlEvents:UIControlEventTouchUpInside];
        [cell.kefu addTarget:self action:@selector(btnTouched:) forControlEvents:UIControlEventTouchUpInside];
        return cell;


    }else{
        
        OrderCell *cell = (OrderCell *)[tableView dequeueReusableCellWithIdentifier:@"cell1"];
        if (arr.count == 0) {
            return cell;
        }
        if (arr.count == 0) {
            return cell;
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        [cell.waiterName autoReSizeWidthForContent:80];
        cell.waiterName.text = order.mSeller.mName;
        CGFloat sss = [cell.waiterName.text sizeWithFont:cell.waiterName.font constrainedToSize:CGSizeMake(MAXFLOAT, cell.waiterName.frame.size.height)].width;
        
        CGRect rrr = cell.waiterName.frame;
        rrr.size.width = sss;
        cell.waiterName.frame = rrr;

        [Util relPosUI:cell.waiterName dif:25 tag:cell.jiantou tagatdic:E_dic_r];
        
        cell.waiterName.text = order.mSeller.mName;
        cell.states.text = order.mOrderStateStr;
        cell.serviceName.text = order.mGooods.mName;
        cell.ServiceNameLb.text = order.mStaff.mName;
        cell.PriceLb.text = [NSString stringWithFormat:@"¥%.2f",order.mGooods.mPrice];
        cell.ordertime.text = order.mApptime;
        cell.address.text = order.mAddress;
        [cell.JigouBtn addTarget:self action:@selector(jigouAction:) forControlEvents:UIControlEventTouchUpInside];
        if (order.mPromMoney==0) {
            cell.fujia.hidden = YES;
            cell.youhui.hidden = YES;
        }
        else
        {
            cell.youhui.hidden = NO;
            cell.fujia.hidden = NO;
        }
        cell.fujia.text = [NSString stringWithFormat:@"¥%.2f",order.mPromMoney];
        cell.total.text =[NSString stringWithFormat:@"¥%.2f",order.mTotalMoney];
        
        [cell.headimg sd_setImageWithURL:[NSURL URLWithString:order.mGooods.mImgURL] placeholderImage:[UIImage imageNamed:@"14.png"]];

        
        cell.headimg.layer.masksToBounds = YES;
        cell.headimg.layer.cornerRadius = 5;
        
        switch ( [order getUIShowbt]) {
            case E_UIShow_NON:
            {
                cell.cancleBtn.hidden = YES;
                cell.payBtn.hidden = YES;
                cell.replyBtn.hidden = YES;
                cell.anyBtn.hidden = YES;
                cell.kefu.hidden = YES;
                
            }
                break;
            case E_UIShow_Cancle_Pay:
            {
                cell.cancleBtn.hidden = NO;
                cell.payBtn.hidden = NO;
                cell.replyBtn.hidden = YES;
                cell.anyBtn.hidden = YES;
                cell.kefu.hidden = YES;
                
            }
                break;
            case E_UIShow_Cancle_ConTa:
            {
                cell.cancleBtn.hidden = NO;
                cell.payBtn.hidden = YES;
                cell.replyBtn.hidden = YES;
                cell.anyBtn.hidden = NO;
                cell.kefu.hidden = YES;
                [cell.anyBtn setTitle:@"联系TA" forState:UIControlStateNormal];
            }
                break;
            case E_UIShow_ConTa_ConKf:
            {
                cell.cancleBtn.hidden = YES;
                cell.payBtn.hidden = YES;
                cell.replyBtn.hidden = YES;
                cell.anyBtn.hidden = NO;
                cell.kefu.hidden = NO;
                [cell.anyBtn setTitle:@"联系TA" forState:UIControlStateNormal];
                
            }
                break;
            case E_UIShow_ConKf:
            {
                cell.cancleBtn.hidden = YES;
                cell.payBtn.hidden = YES;
                cell.replyBtn.hidden = YES;
                cell.anyBtn.hidden = NO;
                //cell.kefu.hidden = NO;
                [cell.anyBtn setTitle:@"联系客服" forState:UIControlStateNormal];
                
            }
                break;
            case E_UIShow_Confim:
            {
                cell.cancleBtn.hidden = YES;
                cell.payBtn.hidden = YES;
                cell.replyBtn.hidden = YES;
                cell.anyBtn.hidden = NO;
                cell.kefu.hidden = YES;
                [cell.anyBtn setTitle:@"确认完成" forState:UIControlStateNormal];
                
            }
                break;
            case E_UIShow_Comment:
            {
                cell.cancleBtn.hidden = YES;
                cell.payBtn.hidden = YES;
                cell.replyBtn.hidden = NO;
                cell.anyBtn.hidden = YES;
                cell.kefu.hidden = YES;
                
            }
                break;
            case E_UIShow_Del:
            {
                cell.cancleBtn.hidden = YES;
                cell.payBtn.hidden = YES;
                cell.replyBtn.hidden = YES;
                cell.anyBtn.hidden = NO;
                cell.kefu.hidden = YES;
                [cell.anyBtn setTitle:@"删除订单" forState:UIControlStateNormal];
                
            }
                break;
            case E_UIShow_Del_ConKf:
            {
                cell.cancleBtn.hidden = YES;
                cell.payBtn.hidden = YES;
                cell.replyBtn.hidden = YES;
                cell.anyBtn.hidden = NO;
                cell.kefu.hidden = NO;
                [cell.anyBtn setTitle:@"删除订单" forState:UIControlStateNormal];
                
            }
                break;
                
                
            default:
                break;
        }
        [cell.cancleBtn addTarget:self action:@selector(btnTouched:) forControlEvents:UIControlEventTouchUpInside];
        [cell.payBtn addTarget:self action:@selector(btnTouched:) forControlEvents:UIControlEventTouchUpInside];
        [cell.replyBtn addTarget:self action:@selector(btnTouched:) forControlEvents:UIControlEventTouchUpInside];
        [cell.anyBtn addTarget:self action:@selector(btnTouched:) forControlEvents:UIControlEventTouchUpInside];
        [cell.kefu addTarget:self action:@selector(btnTouched:) forControlEvents:UIControlEventTouchUpInside];
        return cell;

    }

}
#pragma mark---服务人员
- (void)choiceRenyuan:(UIButton *)sender{
    OrderCell *cell = (OrderCell*)[sender findSuperViewWithClass:[OrderCell class]];
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    SOrder *sorder = [arr objectAtIndex:indexpath.row];
    
    WaiterDetailVC *vc = [[WaiterDetailVC alloc]init];
    vc.sellerStaff = sorder.mStaff;
    [self pushViewController:vc];
    
}
#pragma mark---服务机构
- (void)jigouAction:(UIButton *)sender{
    MLLog(@"机构机构");
    OrderCell *cell = (OrderCell*)[sender findSuperViewWithClass:[OrderCell class]];
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    SOrder *sorder = [arr objectAtIndex:indexpath.row];
    
    ServicerChoiceView *sVC = [[ServicerChoiceView alloc]init];
    sVC.mSellerid = sorder.mSeller.mId;
    [self pushViewController:sVC];
    
}
-(void)btnTouched:(UIButton *)sender
{
    
    if ( [SUser isNeedLogin] ) {
        
        if( !_bgotologin )
        {
            _bgotologin = YES;
            [SVProgressHUD showErrorWithStatus:@"你还未登录"];
            
            [self gotoLoginVC];
        }
        else
        {
            _bgotologin = NO;
        }
        return;
    }
    OrderCell *cell = (OrderCell*)[sender findSuperViewWithClass:[OrderCell class]];
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    SOrder *order = [arr objectAtIndex:indexpath.row];
    NSLog(@"%@",order.mUserName);
    switch (sender.tag) {
        case 10://取消订单
        {
            [SVProgressHUD showWithStatus:@"正在取消..." maskType:SVProgressHUDMaskTypeClear];
            [order cancle:^(SResBase *retobj) {
                if( retobj.msuccess )
                {
                    [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
                    [self.tableView beginUpdates];
                    [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView endUpdates];
                }
                else
                    [SVProgressHUD showErrorWithStatus:retobj.mmsg];
                
            }];
        }
            break;
        case 11://支付按钮
        {
            OrderPayVC *vc = [[OrderPayVC alloc]init];
            vc.order = order;
            vc.comfrom = 2;
            _mybereloadone = indexpath.row;
            [self pushViewController:vc];
        }
            break;
        case 12://评价按钮
        {
            PingjiaVC* vc = [[PingjiaVC alloc]init];
            _mybereloadone = indexpath.row;
            vc.mtagOrder = order;
            [self pushViewController:vc];
        }
            break;
        case 13://任意按钮
            if ([order getUIShowbt]==E_UIShow_Cancle_ConTa||[order getUIShowbt]==E_UIShow_ConTa_ConKf) {
                ///联系ta
                
                NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",order.mPhoneNum];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                
            }else if ([order getUIShowbt]==E_UIShow_Confim)
            {
                //确认完成
                [SVProgressHUD showWithStatus:@"正在确认完成..." maskType:SVProgressHUDMaskTypeClear];
             
                [order confirmThis:^(SResBase *retobj) {
                    if( retobj.msuccess )
                    {
                        [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
                        
                        [self.tableView beginUpdates];
                        [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
                        [self.tableView endUpdates];
                    }
                    else
                        [SVProgressHUD showErrorWithStatus:retobj.mmsg];
                    
                }];
            }
            else if ([order getUIShowbt]==E_UIShow_Del||[order getUIShowbt]==E_UIShow_Del_ConKf)
            {
                //删除订单
                NSInteger _ww = indexpath.row;
                [SVProgressHUD showWithStatus:@"正在删除..." maskType:SVProgressHUDMaskTypeClear];
                [order delThis:^(SResBase *retobj) {
                    if( retobj.msuccess )
                    {
                        [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
                        NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
                        NSArray *arr = [tempDic objectForKey:key2];
                        NSMutableArray* tmpdelarr = [[NSMutableArray alloc]initWithArray:arr];
                        [tmpdelarr removeObjectAtIndex:_ww];
                        [tempDic setObject:tmpdelarr forKey:key2];
                        
                        [self.tableView beginUpdates];
                        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_ww inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                        [self.tableView endUpdates];
                    }
                    else
                        [SVProgressHUD showErrorWithStatus:retobj.mmsg];
                    
                }];
            }
            else if ( [order getUIShowbt]== E_UIShow_ConKf )
            {
                NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",[GInfo shareClient].mServiceTel];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            }
            break;
        case 14://客服按钮
        {
            NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",[GInfo shareClient].mServiceTel];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
            break;
        default:
            break;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [SUser isNeedLogin] ) {
        
        if( !_bgotologin )
        {
            _bgotologin = YES;
            [SVProgressHUD showErrorWithStatus:@"你还未登录"];
            
            [self gotoLoginVC];
        }
        else
        {
            _bgotologin = NO;
        }
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];

    SOrder *order = [arr objectAtIndex:indexPath.row];
    OrderDetailVC *vc = [[OrderDetailVC alloc]init];
    vc.tempOrder = order;
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

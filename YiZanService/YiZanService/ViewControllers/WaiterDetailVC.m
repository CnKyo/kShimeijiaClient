//
//  WaiterDetailVC.m
//  YiZanService
//
//  Created by ljg on 15-3-24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "WaiterDetailVC.h"
#import "WaiterDetailView.h"
#import "ServiceTableCell.h"
#import "ServiceDetailVC.h"
#import "PingJiaList.h"

#import "jubaoViewController.h"
#import "ServicerChoiceView.h"

#import "SellerPromn.h"
@interface WaiterDetailVC ()<UITableViewDataSource,UITableViewDelegate>
{
    UIButton *tempBtn;
    UIImageView *lineImage;
    int        nowSelect;
    UIImageView * paixuImage;
    BOOL isDown;
    UIView *topView;
    NSMutableDictionary *tempDic;
    WaiterDetailView *detailView;
    
    UITableView *mTableView;
}
@end

@implementation WaiterDetailVC
-(void)loadView
{
    self.hiddenTabBar = YES;
    [super loadView];
}
- (void)viewDidLoad {
    self.mPageName= @"商家详情";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    tempDic = [[NSMutableDictionary alloc]init];
#warning 判断是否属于机构or个人
    
    if ( ![self.sellerStaff bshowGroup] ) {
        detailView = [WaiterDetailView shareView];

    }else{
        detailView = [WaiterDetailView shareJigouView];
    }

    [self loadTableView:CGRectMake(0, 0, 320, DEVICE_InNavBar_Height) delegate:self dataSource:self];
    self.haveFooter = YES;
    self.haveHeader = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = detailView;
    
    UINib *nib = [UINib nibWithNibName:@"ServiceTableCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
    [self.tableView headerBeginRefreshing];
  //  [self.contentView addSubview:view];
}
-(void)updatePage
{
    self.Title = self.sellerStaff.mName;
    detailView.userName.text = self.sellerStaff.mName;
    [detailView.headImage sd_setImageWithURL:[NSURL URLWithString:self.sellerStaff.mLogoURL] placeholderImage:DefatultHead];
    detailView.pro.text = [NSString stringWithFormat:@"%f",self.sellerStaff.mCommentSpecialtyAvgScore];
    detailView.chat.text = [NSString stringWithFormat:@"%f",self.sellerStaff.mCommentCommunicateAvgScore];
    detailView.time.text = [NSString stringWithFormat:@"%f",self.sellerStaff.mCommentPunctualityAvgScore];

    detailView.AgeLb.text = [NSString stringWithFormat:@"%d岁",self.sellerStaff.mAge];
    
    UIImage *img1 = [UIImage imageNamed:@"boy"];
    UIImage *img2 = [UIImage imageNamed:@"girl"];
    
    detailView.sexTypeImg.image = self.sellerStaff.mSex == 1 ? img1:img2;
    
    self.rightBtnImage = self.sellerStaff.mFav?[UIImage imageNamed:@"13-1.png"]:[UIImage imageNamed:@"13.png"];
    
    NSString *pricestr = [NSString stringWithFormat:@"均价：¥%.2f",self.sellerStaff.mGoodsAvgPrice];
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc]initWithString:pricestr];
    [atr addAttribute:NSForegroundColorAttributeName value:COLOR(104, 104, 104) range:NSMakeRange(0,3)];
    detailView.pricelabel.attributedText = atr;
    detailView.orderlabel.text = [NSString stringWithFormat:@"接单数：%d",self.sellerStaff.mOrderCount];
    detailView.headImage.layer.masksToBounds = YES;
    detailView.headImage.layer.cornerRadius = 30;
    
    [detailView.jubaoBtn addTarget:self action:@selector(jubaoAction:) forControlEvents:UIControlEventTouchUpInside];
    [detailView.requestYouhuiquanBtn addTarget:self action:@selector(RequestAction:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)rightBtnTouched:(id)sender
{
    if (isDown == YES) {
        
        [SVProgressHUD showWithStatus:@"取消收藏" maskType:SVProgressHUDMaskTypeClear];
        
        [self.sellerStaff Favit:^(SResBase *resb) {
            if (resb.msuccess) {
                [SVProgressHUD dismiss];
                self.rightBtnImage = self.sellerStaff.mFav?[UIImage imageNamed:@"13-1.png"]:[UIImage imageNamed:@"13.png"];
                
            }else
            {
                [SVProgressHUD showErrorWithStatus:resb.mmsg];
            }
        }];
        isDown = NO;
        
    }else if (isDown == NO){
        
        [SVProgressHUD showWithStatus:@"收藏成功" maskType:SVProgressHUDMaskTypeClear];
        [self.sellerStaff Favit:^(SResBase *resb) {
            if (resb.msuccess) {
                [SVProgressHUD dismiss];
                self.rightBtnImage = self.sellerStaff.mFav?[UIImage imageNamed:@"13-1.png"]:[UIImage imageNamed:@"13.png"];
                
            }else
            {
                [SVProgressHUD showErrorWithStatus:resb.mmsg];
            }
        }];
        isDown = YES;
        
    }
    
}
#pragma mark----举报事件
#warning 举报按钮
- (void)jubaoAction:(UIButton *)sender{
    
    jubaoViewController *jubaoVC = [[jubaoViewController alloc]init];
    jubaoVC.mtype = 2;
    jubaoVC.mId = self.sellerStaff.mId;
    [self pushViewController:jubaoVC];

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

        if (![tempDic objectForKey:key1]||(sender.tag ==12&&tempBtn == sender)) {
            if (sender.tag == 12&&tempBtn == sender) {
                isDown = !isDown;
                paixuImage.image = isDown?[UIImage imageNamed:@"img_down.png"]:[UIImage imageNamed:@"img_up.png"];
            }
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
-(void)headerBeganRefresh
{
    [self.sellerStaff getDetail:^(SResBase *resb) {
        if (resb.msuccess) {
            
            [self updatePage];

            detailView.pro.text = [NSString stringWithFormat:@"%.1f",self.sellerStaff.mCommentSpecialtyAvgScore];
            detailView.chat.text = [NSString stringWithFormat:@"%.1f",self.sellerStaff.mCommentCommunicateAvgScore];
            detailView.time.text = [NSString stringWithFormat:@"%.1f",self.sellerStaff.mCommentPunctualityAvgScore];
            detailView.userreply.text = [NSString stringWithFormat:@"顾客评价(%d)",self.sellerStaff.mCommentTotalCount];
            [detailView.replyDetail addTarget:self action:@selector(gotoPingjia:) forControlEvents:UIControlEventTouchUpInside];
            [detailView.requestYouhuiquanBtn addTarget:self action:@selector(RequestAction:) forControlEvents:UIControlEventTouchUpInside];

            if( [self.sellerStaff bshowGroup] )
                detailView.JigouLb.text = self.sellerStaff.mSellerObj.mName;
            [detailView.JigouBtn addTarget:self action:@selector(choiceJigouAction:) forControlEvents:UIControlEventTouchUpInside];

        }else
        {
            [self showErrorStatus:resb.mmsg];
        }
    }];
    
    self.page = 1;
    [SGoods getGoods:0 order:nowSelect sort:nowSelect==3?!isDown:0 page:(int)self.page keywords:nil sellerid:self.sellerStaff.mSellerObj.mId staffid:self.sellerStaff.mId aptime:nil lng:0 lat:0 block:^(SResBase *resb, NSArray *all) {
        [self headerEndRefresh];
        if (resb.msuccess) {
            [self.tempArray removeAllObjects];
//            NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
//
//            if (all.count!=0) {
//                [self removeEmptyView];
//                
//                [tempDic setObject:all forKey:key2];
//            }else
//            {
//                [tempDic setObject:[NSMutableArray new] forKey:key2];
//                //  [SVProgressHUD showErrorWithStatus:@"暂无数据"];
//                [self addEmptyView:@"暂无数据"];
//                
//            }
            [self.tempArray addObjectsFromArray:all];

        }else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
            [self addEmptyView:resb.mmsg];
        }
        [self.tableView reloadData];

    }];

}
#pragma mark ----选择机构
- (void)choiceJigouAction:(UIButton *)sender{
    
    ServicerChoiceView *choiceView = [[ServicerChoiceView alloc]init];
    choiceView.mSellerid = self.sellerStaff.mSellerObj.mId;
    
    [self pushViewController:choiceView];
}
-(void)footetBeganRefresh
{
    self.page++;
    [SGoods getGoods:0 order:nowSelect sort:nowSelect==3?isDown:0 page:(int)self.page keywords:nil sellerid:self.sellerStaff.mSellerObj.mId staffid:self.sellerStaff.mId aptime:nil lng:0 lat:0 block:^(SResBase *resb, NSArray *all) {
        [self footetEndRefresh];

        if (resb.msuccess) {
            [self.tempArray removeAllObjects];

//            NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
//
//            
//            NSArray *oldarr = [tempDic objectForKey:key2];
//
//            if (all.count!=0) {
//                [self removeEmptyView];
//                
//                NSMutableArray *array = [NSMutableArray array];
//                if (oldarr) {
//                    [array addObjectsFromArray:oldarr];
//                }
//                [array addObjectsFromArray:all];
//                [tempDic setObject:array forKey:key2];
            
//            }else
//            {
//                if(!oldarr||oldarr.count==0)
//                {
//                    [SVProgressHUD showErrorWithStatus:@"暂无数据"];
//                }
//                else
//                    [SVProgressHUD showErrorWithStatus:@"暂无新数据"];
//                //   [self addEmptyView:@"暂无数据"];
//
//            }
//            [self.tableView reloadData];
            [self.tempArray addObjectsFromArray:all];


        }else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
            // [self addEmptyView:resb.mmsg];
        }
    }];

}
- (void)RequestAction:(UIButton *)sender{
    SellerPromn *SellerVC = [[SellerPromn alloc]init];
    SellerVC.mSellerid = _sellerStaff.mSellerObj.mId;
    [self pushViewController:SellerVC];
}
#pragma mark -- tableviewDelegate
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (topView) {
        return topView;
    }
        topView  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    topView.layer.borderWidth = 1.0;
    topView.layer.borderColor = COLOR(232, 232, 232).CGColor;
        topView.backgroundColor = [UIColor whiteColor];
        float x = 0;
        for (int i =0; i<3; i++) {
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, 106, 45)];
            [btn setTitle:@"综合排序" forState:UIControlStateNormal];
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
                [btn setTitle:@"人气优先" forState:UIControlStateNormal];
                [btn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];

            }
            else
            {
                [btn setTitle:@"价格排序" forState:UIControlStateNormal];
                [btn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];
                paixuImage = [[UIImageView alloc]initWithFrame:CGRectMake(x+90, 17, 11, 11)];
                paixuImage.image = [UIImage imageNamed:@"img_down.png"];
                // paixuImage.backgroundColor = [UIColor redColor];
                isDown = YES;
                [topView addSubview:paixuImage];

            }
            btn.tag = 10+i;
            [btn addTarget:self action:@selector(topbtnTouched:) forControlEvents:UIControlEventTouchUpInside];
            x+=106;
        }

        UIImageView *xianimg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 44, 320, 1)];
        xianimg.backgroundColor  = COLOR(232, 232, 232);
        [topView addSubview:xianimg];
        //[self.contentView addSubview:topView];
    return topView;

}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

//    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
//    NSArray *arr = [tempDic objectForKey:key2];
    return self.tempArray.count%2==0?self.tempArray.count/2:self.tempArray.count/2+1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 206;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* Rcell = @"cell";

    ServiceTableCell* cell = [tableView dequeueReusableCellWithIdentifier:Rcell];


//    cell.img1.layer.masksToBounds = YES;
//    cell.img1.layer.cornerRadius = 3;
//    cell.img2.layer.masksToBounds = YES;
//    cell.img2.layer.cornerRadius = 3;
    
//    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
//    NSArray *arr = [tempDic objectForKey:key2];
    
    SGoods *item1 = self.tempArray[indexPath.row*2];
    SGoods *item2 = self.tempArray[indexPath.row*2+1];

    
    if ((indexPath.row+1)*2>self.tempArray.count) {
        cell.view2.hidden = YES;
    }
    else
    {
        cell.view2.hidden = NO;
    }

    cell.title1.text = item1.mName;
    cell.title2.text = item2.mName;
    cell.price1.text = [NSString stringWithFormat:@"¥%.2f",item1.mPrice];
    cell.price2.text = [NSString stringWithFormat:@"¥%.2f",item2.mPrice];
    [cell.btn1 addTarget:self action:@selector(fooBtn1Touched:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn2 addTarget:self action:@selector(fooBtn2Touched:) forControlEvents:UIControlEventTouchUpInside];
    
//    [cell.img1 sd_setImageWithURL:[NSURL URLWithString:item1.mImgURL] placeholderImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:item1.mImgURL]]]];
//    [cell.img2 sd_setImageWithURL:[NSURL URLWithString:item2.mImgURL] placeholderImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:item2.mImgURL]]]];

    [cell.img1 sd_setImageWithURL:[NSURL URLWithString:item1.mImgURL] placeholderImage:[UIImage imageNamed:@"img_def"]];
    [cell.img2 sd_setImageWithURL:[NSURL URLWithString:item2.mImgURL] placeholderImage:[UIImage imageNamed:@"img_def"]];
    return cell;
}
-(void)fooBtn1Touched:(UIButton *)sender
{
    ServiceTableCell *cell = (ServiceTableCell*)[sender findSuperViewWithClass:[ServiceTableCell class]];
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
//    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
//    NSArray *arr = [tempDic objectForKey:key2];

    SGoods *item = [self.tempArray objectAtIndex:index.row*2];

    ServiceDetailVC *avc = [[ServiceDetailVC alloc]init];
    avc.goods = item;
    avc.goods.mSellerStaff = self.sellerStaff;
    [self pushViewController:avc];
    //  [jiageArray removeObjectAtIndex:index.row];
    // [self pushViewController:vc animated:YES IsCancelConnections:YES];

}
-(void)fooBtn2Touched:(UIButton *)sender
{
    ServiceTableCell *cell = (ServiceTableCell*)[sender findSuperViewWithClass:[ServiceTableCell class]];
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    //  [jiageArray removeObjectAtIndex:index.row];
//    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
//    NSArray *arr = [tempDic objectForKey:key2];

    SGoods *item = [self.tempArray objectAtIndex:index.row*2+1];
    ServiceDetailVC *avc = [[ServiceDetailVC alloc]init];
    avc.goods = item;
    avc.goods.mSellerStaff = self.sellerStaff;
    [self pushViewController:avc];
    
}

-(void)gotoPingjia:(UIButton*)sender
{
    PingJiaList* vc = [[PingJiaList alloc] init];
    vc.mStaff = self.sellerStaff;
    vc.mGoods = nil;
    MLLog(@"dasdasdpjpjpjpjpj");
    
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

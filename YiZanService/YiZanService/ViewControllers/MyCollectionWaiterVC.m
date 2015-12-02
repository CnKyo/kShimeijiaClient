//
//  MyCollectionWaiterVC.m
//  YiZanService
//
//  Created by ljg on 15-3-24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "MyCollectionWaiterVC.h"
#import "WaiterCell.h"
#import "WaiterDetailVC.h"
#import "ServicerChoiceCell.h"


@interface MyCollectionWaiterVC ()<UITableViewDelegate,UITableViewDataSource>
{
    UIButton *tempBtn;
    UIImageView *lineImage;
    int nowSelect;
    NSMutableDictionary *tempDic;
    BOOL isDown;
    UIImageView *paixuImage;
}
@end

@implementation MyCollectionWaiterVC
-(id)init
{
    self = [super init];
    if (self) {
        //MLLog_VC("init");
        //    self.isCancelConectionsWhenviewDidDisappear = YES;
        //  originY = 0;
        //   vcType = kViewController_MainVC;
        self.view.backgroundColor = COLOR(238, 234, 233);
        NSLog(@"--------->isnotnib");

    }
    return self;

}
-(void)loadView
{
    [super loadView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tempDic = [[NSMutableDictionary alloc]init];
    self.mPageName = @"收藏手艺人";
    [self loadTableView:CGRectMake(0, 0, 320, DEVICE_InNavBar_Height) delegate:self dataSource:self];
    
    UINib *nib = [UINib nibWithNibName:@"ServicerChoiceCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
    self.haveFooter = YES;
    self.haveHeader = YES;
    [self.tableView headerBeginRefreshing];
}
-(void)headerBeganRefresh
{
    __block NSInteger page ;

    NSString *key1 = [NSString stringWithFormat:@"nowselectpage%d",nowSelect];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];

    //    if ([tempDic objectForKey:key1]) {
    //        page = [[tempDic objectForKey:key1]integerValue];
    //    }
    //    else
    page = 1;


    //    [SSeller getSellerList:nowSelect sort:nowSelect sort:nowSelect==3?!isDown:0 keywords:nil lng:0 lat:0 page:page block:^(SResBase *resb, NSArray *all) {
    //
    //    }];
    [[SAppInfo shareClient]getUserLocation:NO block:^(NSString *err) {

        [[SUser currentUser]getFavStaffList:(int)page block:^(SResBase *resb, NSArray *all) {
            [self headerEndRefresh];
            if (resb.msuccess) {

                if (all.count!=0) {
                    [self removeEmptyView];
                    page++;
                    [tempDic setObject:NumberWithInt((int)page) forKey:key1];
                    [tempDic setObject:all forKey:key2];
                }else
                {
                    [tempDic setObject:[NSArray array] forKey:key2];
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

    }];

}
-(void)footetBeganRefresh
{
    __block NSInteger page ;

    NSString *key1 = [NSString stringWithFormat:@"nowselectpage%d",nowSelect];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];

    if ([tempDic objectForKey:key1]) {
        page = [[tempDic objectForKey:key1]integerValue];
    }
    else
        page = 1;
    [[SAppInfo shareClient]getUserLocation:NO block:^(NSString *err) {

        [[SUser currentUser]getFavStaffList:(int)page block:^(SResBase *resb, NSArray *all) {
            [self footetEndRefresh];

            if (resb.msuccess) {
                NSArray *oldarr = [tempDic objectForKey:key2];

                if (all.count!=0) {
                    [self removeEmptyView];
                    page++;

                    NSMutableArray *array = [NSMutableArray array];
                    if (oldarr) {
                        [array addObjectsFromArray:oldarr];
                    }
                    [array addObjectsFromArray:all];
                    [tempDic setObject:NumberWithInt((int)page) forKey:key1];
                    [tempDic setObject:array forKey:key2];
                }else
                {
                    if(!oldarr||oldarr.count==0)
                    {
                        [SVProgressHUD showErrorWithStatus:@"暂无数据"];
                    }
                    else
                        [SVProgressHUD showErrorWithStatus:@"暂无新数据"];
                    //   [self addEmptyView:@"暂无数据"];

                }
                [self.tableView reloadData];

            }else
            {
                [SVProgressHUD showErrorWithStatus:resb.mmsg];
                // [self addEmptyView:resb.mmsg];
            }
        }];

    }];

}

#pragma mark tableviewDelegate
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
    return 85;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    //    WaiterCell *cell = (WaiterCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    ServicerChoiceCell *cell = (ServicerChoiceCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    SStaff *one = [arr objectAtIndex:indexPath.row];
    
    [cell.HeaderImg sd_setImageWithURL:[NSURL URLWithString:one.mLogoURL] placeholderImage:[UIImage imageNamed:@"otherhead"]];
    cell.HeaderImg.layer.masksToBounds = YES;
    cell.HeaderImg.layer.cornerRadius = 30;
    cell.JuliLb.text = [NSString stringWithFormat:@"距离%@",one.mDist];
    NSString *pricestr = [NSString stringWithFormat:@"均价：¥%.2f",one.mGoodsAvgPrice];
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc]initWithString:pricestr];
    [atr addAttribute:NSForegroundColorAttributeName value:COLOR(104, 104, 104) range:NSMakeRange(0,3)];
    
    //    cell.pricelabel.attributedText = atr;
    cell.JieOrdersLb.text = [NSString stringWithFormat:@"接单%d次",one.mOrderCount];
    //    [cell.mcreatR sd_setImageWithURL:[NSURL URLWithString: one.mCreditRank ] placeholderImage:nil];
    
    
    cell.NameLb.text = one.mName;
    
    UIImage *img2 = [UIImage imageNamed:@"boy"];
    UIImage *img1 = [UIImage imageNamed:@"girl"];
    
    cell.SexTypeImg.image = one.mSex == 1 ? img2:img1;
    
    //    ///自动锁房宽度80
    //    [cell.namelabel autoReSizeWidthForContent:80];
    //    [Util relPosUI:cell.namelabel dif:5 tag:cell.TypeImg tagatdic:E_dic_r];
    
    cell.BtnUnselected.hidden = YES;
    
 
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *key2 = [NSString stringWithFormat:@"nowselectdata%d",nowSelect];
    NSArray *arr = [tempDic objectForKey:key2];
    SStaff *one = [arr objectAtIndex:indexPath.row];
    
    WaiterDetailVC *vc = [[WaiterDetailVC alloc]init];
    vc.sellerStaff = one;
    [(BaseVC*)self.parentViewController pushViewController:vc];
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

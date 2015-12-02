//
//  messageView.m
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/16.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "messageView.h"
#import "messageCell.h"

#import "messageDetailView.h"
#import "WebVC.h"

#import "OrderVC.h"
@interface messageView ()<UITableViewDataSource,UITableViewDelegate>
{
    messageCell *cell;
}
@end

@implementation messageView
- (void)loadView{
    self.hiddenTabBar = YES;
    [super loadView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([SUser isNeedLogin]) {
        [self gotoLoginVC];
        return;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mPageName = @"消息列表";
    self.Title = self.mPageName;
    [self setRightBtnWidth:133];
    self.rightBtnTitle = @"全部设为已读";
    [self.navBar.rightBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self loadTableView:CGRectMake(0, 0, 320, DEVICE_InNavBar_Height) delegate:self dataSource:self];
    
    self.haveFooter = YES;
    self.haveHeader = YES;
    
    UINib *nib = [UINib nibWithNibName:@"messageCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView headerBeginRefreshing];    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ----顶部刷新数据
- (void)headerBeganRefresh{
    [SVProgressHUD showWithStatus:@"正在获取数据..." maskType:SVProgressHUDMaskTypeClear];
    self.page = 1;
    [SMessage getMsgList:self.page block:^(SResBase *resb, NSArray *all) {
        [self headerEndRefresh];
        
        [self.tempArray removeAllObjects];
        if (resb.msuccess) {
            [self.tempArray addObjectsFromArray:all];
            MLLog(@"获取到的数据:%@",self.tempArray);
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
        [self.tableView reloadData];
    }];
    

}
#pragma mark----地步刷新
-(void)footetBeganRefresh
{
    [SVProgressHUD showWithStatus:@"正在获取数据..." maskType:SVProgressHUDMaskTypeClear];
    self.page ++;
    [SMessage getMsgList:self.page block:^(SResBase *resb, NSArray *all) {
        [self footetEndRefresh];
        if (resb.msuccess) {
            
            [self.tempArray addObjectsFromArray:all];
            [self.tableView reloadData];
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
    
}

#pragma mark ----列表代理方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    cell = (messageCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.typeView.layer.masksToBounds = YES;
    cell.typeView.layer.cornerRadius = 2;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    SMessage *Smsg = self.tempArray[indexPath.row];

    NSArray *timeArr = [Smsg.mDateStr componentsSeparatedByString:@" "];
    
    cell.msgtitleLb.text = Smsg.mTitle;
    cell.msgContentLb.text = Smsg.mContent;
    
    cell.msgTimeLb.text = [timeArr objectAtIndex:0];
    
    if (Smsg.mType == 1) {
        cell.typeLb.text = @"平台";
    }if (Smsg.mType == 2) {
        cell.typeLb.text = @"商家";
    }if (Smsg.mType == 3) {
        cell.typeLb.text = @"订单";

    }

    if (Smsg.mBread == NO) {
        MLLog(@"~~~~~:%d",Smsg.mBread);
        cell.msgPoint.hidden = NO;


    }
    if(Smsg.mBread == YES){
        MLLog(@"~~~~~:%d",Smsg.mBread);
        cell.msgPoint.hidden = YES;

    }

    return cell;
    
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tempArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    SMessage *Smsg = self.tempArray[indexPath.row];
    
    Smsg.mBread = YES;
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
    [Smsg readit];
    
  
    [tableView reloadData];
    if (Smsg.mType == 1)
    {///状态为1，打开新界面，展示消息详情
        messageDetailView *msgDetail = [[messageDetailView alloc]initWithNibName:@"messageDetailView" bundle:nil];
        msgDetail.msgObj = Smsg;
        [self pushViewController:msgDetail];
    }
    if (Smsg.mType == 3)
    {///3为订单消息,args为订单id???
        
        OrderVC *oderMsgVC = [[OrderVC alloc]init];
        [self pushViewController:oderMsgVC];
        
        
    }if(Smsg.mType == 2)
    {///状态为2，打开html界面

        WebVC *webView = [[WebVC alloc]init];
        webView.mName = @"消息详情";
        webView.mUrl = Smsg.mArgs;
        [self pushViewController:webView];
        
    }

}
#pragma mark-----全部设为已读
- (void)rightBtnTouched:(id)sender{
    MLLog(@"全部设为已读");
    [SVProgressHUD showWithStatus:@"正在操作中..." maskType:SVProgressHUDMaskTypeClear];

    [SMessage readAllMessage:^(SResBase *retobj) {
        if (retobj.msuccess) {
            [SVProgressHUD dismiss];
            for (SMessage *one in self.tempArray) {
                one.mBread = YES;
            }
            [self.tableView reloadData];
        }
        else{
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
        }
    }];
    
}
@end

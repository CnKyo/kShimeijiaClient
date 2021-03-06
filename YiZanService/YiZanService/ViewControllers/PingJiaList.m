//
//  PingJiaList.m
//  YiZanService
//
//  Created by zzl on 15/3/30.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "PingJiaList.h"
#import "PingJiaCell.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import <objc/runtime.h>

@interface PingJiaList ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation PingJiaList
{
    
    UIView*     _topselev;
    UILabel*    _lineview;
    UIButton*   _lastcliecke;
    
}
-(void)loadView
{
    self.hiddenTabBar = YES;
    [super loadView];
}

-(void)dealloc
{
    self.mGoods = nil;
    self.mStaff = nil;
}
- (void)viewDidLoad {
    self.mPageName = @"顾客评价";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.Title = self.mPageName;
    
    _topselev = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_Width, 50)];
    _topselev.backgroundColor = [UIColor whiteColor];
    
    float x = 0;
    UIButton* btall = [[UIButton alloc]initWithFrame:CGRectMake(x, 10, _topselev.frame.size.width/4, 30)];
    int intv = 0;
    
    intv = self.mStaff ? self.mStaff.mCommentTotalCount : self.mGoods.mCommentTotalCount;
    
    [btall setTitle:[NSString stringWithFormat:@"全部%d",intv] forState:UIControlStateNormal];

    [btall addTarget:self action:@selector(topclicked:) forControlEvents:UIControlEventTouchUpInside];
    btall.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    btall.tag = 50;
    [_topselev addSubview:btall];
    
    x +=_topselev.frame.size.width/4;
    UIButton* good = [[UIButton alloc]initWithFrame:CGRectMake(x, 10, _topselev.frame.size.width/4, 30)];
    
    intv = self.mStaff ? self.mStaff.mCommentGoodCount : self.mGoods.mCommentGoodCount;
    [good setTitle:[NSString stringWithFormat:@"好评%d",intv] forState:UIControlStateNormal];
    [good addTarget:self action:@selector(topclicked:) forControlEvents:UIControlEventTouchUpInside];
    good.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    good.tag = 51;
    [good setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_topselev addSubview:good];
    
    x +=_topselev.frame.size.width/4;
    UIButton* mid = [[UIButton alloc]initWithFrame:CGRectMake(x, 10, _topselev.frame.size.width/4, 30)];
    
    intv = self.mStaff ? self.mStaff.mCommentNeutralCount : self.mGoods.mCommentNeutralCount;
    
    [mid setTitle:[NSString stringWithFormat:@"中评%d",intv] forState:UIControlStateNormal];
    [mid addTarget:self action:@selector(topclicked:) forControlEvents:UIControlEventTouchUpInside];
    mid.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    mid.tag = 52;
    [mid setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_topselev addSubview:mid];
    
    
    x +=_topselev.frame.size.width/4;
    UIButton* bad = [[UIButton alloc]initWithFrame:CGRectMake(x, 10, _topselev.frame.size.width/4, 30)];

    intv = self.mStaff ? self.mStaff.mCommentBadCount : self.mGoods.mCommentBadCount;

    [bad setTitle:[NSString stringWithFormat:@"差评%d",intv] forState:UIControlStateNormal];
    [bad addTarget:self action:@selector(topclicked:) forControlEvents:UIControlEventTouchUpInside];
    bad.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    bad.tag = 53;
    [bad setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_topselev addSubview:bad];
    
    _lineview = [[UILabel alloc]initWithFrame:CGRectMake(0, 47,45, 2)];
    _lineview.backgroundColor = [UIColor colorWithRed:0.984 green:0.373 blue:0.588 alpha:1.000];
    
    UIView* vv =[[UIView alloc]initWithFrame:CGRectMake(0, 49, _topselev.frame.size.width, 0.5f)];
    vv.backgroundColor = [UIColor colorWithRed:0.867 green:0.859 blue:0.859 alpha:1.000];
    [_topselev addSubview:vv];
    [_topselev addSubview:_lineview];
    
    
    [self.contentView addSubview:_topselev];
    
    _lastcliecke = nil;
    [self topclicked:btall];
    
    [self loadTableView:CGRectMake(0, 50, DEVICE_Width, self.contentView.bounds.size.height - 50) delegate:self dataSource:self];
    self.haveFooter = YES;
    self.haveHeader = YES;
    
    UINib* xib = [UINib nibWithNibName:@"PingJiaCell" bundle:nil];
    [self.tableView registerNib:xib forCellReuseIdentifier:@"cell"];
    
    [self.tableView headerBeginRefreshing];
}

-(void)headerBeganRefresh
{
    self.page = 1;
    [SStaff getComments:(int)_lineview.tag page:self.page goodsid:self.mGoods.mId stafid:self.mStaff.mId block:^(SResBase *resb, NSArray *arr) {
        
        [self.tableView headerEndRefreshing];
        if( resb.msuccess )
        {
            [self.tempArray removeAllObjects];
            [self.tempArray addObjectsFromArray: arr];
            [self.tableView reloadData];
        }
        else
        {
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
-(void)footetBeganRefresh
{
    self.page++;
    [SStaff getComments:(int)_lineview.tag page:self.page goodsid:self.mGoods.mId stafid:self.mStaff.mId block:^(SResBase *resb, NSArray *arr) {
        
        [self.tableView footerEndRefreshing];
        if( resb.msuccess )
        {
            
            [self.tempArray addObjectsFromArray: arr];
            [self.tableView reloadData];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        
        if( self.tempArray.count == 0)
        {
            [self addEmptyViewWithImg:nil];
        }
        else
        {
            [self removeEmptyView];
        }
    }];
}

-(void)topclicked:(UIButton*)sender
{
    if( _lastcliecke == sender) return;
    
    [_lastcliecke setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sender setTitleColor:_lineview.backgroundColor forState:UIControlStateNormal];
    _lastcliecke = sender;
    _lineview.tag = sender.tag - 50;
    
    [UIView animateWithDuration:0.15 animations:^{
        
        CGRect f = _lineview.frame;
        f.origin.x = _lastcliecke.frame.origin.x+18;
        _lineview.frame = f;
        
    }];
    
    [self.tableView headerBeginRefreshing];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tempArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SComments* obj = self.tempArray[ indexPath.row ];
    if( obj.mCellH == 0.0f )
    {
        CGSize its = [obj.mContent sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(237.0f, CGFLOAT_MAX)];
        obj.mTextH = its.height;
        
        obj.mCellH += obj.mTextH + 50;
        if( obj.mAllImgs.count )
        {
            obj.mCellH += 71.0f + 5;
        }
        
        obj.mCellH += 21 + 5 + 5;
    }
    return obj.mCellH;
}
char* g_asskey = "g_asskey";
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SComments* obj = self.tempArray[ indexPath.row ];
    PingJiaCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    
    [cell.mhead sd_setImageWithURL:[NSURL URLWithString:obj.mUserHeadURL] placeholderImage:[UIImage imageNamed:@"redhead"]];
    cell.mhead.layer.borderColor = [[UIColor whiteColor]CGColor];
    cell.mhead.layer.borderWidth = 0.5f;
    cell.mhead.layer.cornerRadius = cell.mhead.frame.size.height/2;
    
    cell.mPhone.text = obj.mPhone;
    cell.mlevel.text = obj.mLevel;
    cell.mcontext.text = obj.mContent;
    cell.mtime.text = obj.mTimeStr;
    
    CGRect f = cell.mcontext.frame;
    f.size.height = obj.mTextH;
    cell.mcontext.frame = f;
    
    if( obj.mAllImgs.count )
    {
        cell.mmidimg.hidden = NO;
        for ( int  j = 0 ; j < 3 && j < obj.mAllImgs.count; j++) {
            NSString* oneurl = obj.mAllImgs[j];
            UIImageView* oneimg = (UIImageView*) [cell.mmidimg viewWithTag: 10+j];
            [oneimg sd_setImageWithURL:[NSURL URLWithString:oneurl] placeholderImage:[UIImage imageNamed:@"img_def"]];
            if( !oneimg.userInteractionEnabled )
            {
                UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick:)];
                [oneimg addGestureRecognizer:tap];
                oneimg.userInteractionEnabled  = YES;
            }
            
            objc_setAssociatedObject(oneimg, g_asskey, nil, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(oneimg, g_asskey, obj, OBJC_ASSOCIATION_ASSIGN);
            
        }
        [Util relPosUI:cell.mcontext dif:5.0f tag:cell.mmidimg tagatdic:E_dic_b];
        [Util relPosUI:cell.mmidimg dif:5.0f tag:cell.mtime tagatdic:E_dic_b];
    }
    else
    {
        cell.mmidimg.hidden = YES;
        [Util relPosUI:cell.mcontext dif:5.0f tag:cell.mtime tagatdic:E_dic_b];
    }
    
    if( [obj.mLevel isEqualToString:@"好评"] )
    {
        cell.mlevel.textColor = [UIColor colorWithRed:0.953 green:0.353 blue:0.553 alpha:1.000];
    }
    else if( [obj.mLevel isEqualToString:@"中评"] )
    {
        cell.mlevel.textColor = [UIColor colorWithRed:0.933 green:0.553 blue:0.235 alpha:1.000];
    }
    else
    {
        cell.mlevel.textColor = [UIColor colorWithRed:0.706 green:0.702 blue:0.706 alpha:1.000];
    }
    
    
    return cell;
}
-(void)imageClick:(UITapGestureRecognizer*)sender
{
    UIImageView* tagv = (UIImageView*)sender.view;
    SComments* onecmm = objc_getAssociatedObject(tagv, g_asskey);
    NSMutableArray* allimgs = NSMutableArray.new;
    for ( NSString* url in onecmm.mAllBigImgs )
    {
        MJPhoto* onemj = [[MJPhoto alloc]init];
        onemj.url = [NSURL URLWithString:url ];
        onemj.srcImageView = tagv;
        [allimgs addObject: onemj];
    }
    
    MJPhotoBrowser* browser = [[MJPhotoBrowser alloc]init];
    browser.currentPhotoIndex = tagv.tag-10;
    browser.photos  = allimgs;
    [browser show];
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

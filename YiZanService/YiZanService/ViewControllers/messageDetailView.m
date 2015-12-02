//
//  messageDetailView.m
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/17.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "messageDetailView.h"
#import "UIView+Additions.h"
#import "UIViewExt.h"
@interface messageDetailView ()

@end

@implementation messageDetailView
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([SUser isNeedLogin]) {
        [self gotoLoginVC];
        return;
    }
}
- (void)loadView{
    [super loadView];
    
    self.hiddenTabBar = YES;
    self.mPageName = @"消息";
    self.Title = self.mPageName;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contentView.backgroundColor = [UIColor colorWithRed:0.933 green:0.918 blue:0.914 alpha:1];
    [self initView];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark----普通消息页面
- (void)initView{
    
    
    CGSize sss =  [_msgContentLb.text sizeWithFont:_msgContentLb.font constrainedToSize:CGSizeMake(_msgContentLb.frame.size.width, CGFLOAT_MAX)];
        
    _msgContentLb.frame = CGRectMake(15,131, 290, sss.height);
    _bottomLineView.frame = CGRectMake(15, _msgContentLb.bottom+10, 305, 1);
    _msgTitle.text = _msgObj.mTitle;
    _msgContentLb.text = _msgObj.mContent;
    _msgTimeLb.text = _msgObj.mDateStr;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

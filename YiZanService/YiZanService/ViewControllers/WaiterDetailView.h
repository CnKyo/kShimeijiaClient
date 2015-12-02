//
//  WaiterDetailView.h
//  YiZanService
//
//  Created by ljg on 15-3-24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaiterDetailView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *pricelabel;
@property (weak, nonatomic) IBOutlet UILabel *orderlabel;
@property (weak, nonatomic) IBOutlet UILabel *pro;
@property (weak, nonatomic) IBOutlet UILabel *chat;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *userreply;
@property (weak, nonatomic) IBOutlet UIButton *replyDetail;


@property (weak, nonatomic) IBOutlet UIImageView *mcreatR;

@property (weak, nonatomic) IBOutlet UIButton *jubaoBtn;
@property (weak, nonatomic) IBOutlet UIButton *JigouBtn;
@property (weak, nonatomic) IBOutlet UILabel *JigouLb;


@property (weak, nonatomic) IBOutlet UILabel *jiedanNumLb;
@property (weak, nonatomic) IBOutlet UIImageView *sexTypeImg;
@property (weak, nonatomic) IBOutlet UILabel *AgeLb;
///领取优惠券
@property (weak, nonatomic) IBOutlet UIButton *requestYouhuiquanBtn;

+(WaiterDetailView *)shareView;

+ (WaiterDetailView *)shareJigouView;
@end

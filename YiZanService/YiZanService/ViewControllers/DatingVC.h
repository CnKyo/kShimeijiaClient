//
//  DatingVC.h
//  YiZanService
//
//  Created by zzl on 15/3/24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "BaseVC.h"

@class CunsomLabel;
@interface DatingVC : BaseVC

@property (nonatomic,strong) NSString*  mwhatFunc;//"预约美甲"

@property (weak, nonatomic) IBOutlet UIScrollView *mwarpsc;


@property (weak, nonatomic) IBOutlet UIView *mwarp;

@property (weak, nonatomic) IBOutlet UITextField *minputNu;
@property (weak, nonatomic) IBOutlet UIButton *mseltimebt;
@property (weak, nonatomic) IBOutlet CunsomLabel *mseladdr;

@property (weak, nonatomic) IBOutlet UIView *mv1;
@property (weak, nonatomic) IBOutlet UIView *mv2;

@property (weak, nonatomic) IBOutlet UIButton *mcatlog;
@property (weak, nonatomic) IBOutlet UIImageView *mtttimg;

@property (weak, nonatomic) IBOutlet UITableView *mcatlogtableview;

@property (weak, nonatomic) IBOutlet UIImageView *marrimg;
@property (weak, nonatomic) IBOutlet UIButton *mdatbt;

@property (weak, nonatomic) IBOutlet UIImageView *mlocicon;


@end

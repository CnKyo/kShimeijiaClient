//
//  searchInMap.h
//  YiZanService
//
//  Created by zzl on 15/3/23.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "BaseVC.h"

@interface searchInMap : BaseVC

@property (nonatomic,strong)    void(^itblock)(NSString* addr,float lng,float lat);

@end

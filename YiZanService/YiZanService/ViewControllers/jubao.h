//
//  jubao.h
//  YiZanService
//
//  Created by 密码为空！ on 15/4/24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQTextView.h"
@interface jubao : UIView
@property (weak, nonatomic) IBOutlet IQTextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *jubaoBtn;
+ (jubao *)shareView;
@end

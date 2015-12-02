//
//  LoginView.h
//  YiZanService
//
//  Created by ljg on 15-3-20.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginView : UIView
@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UIView *passView;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *forgetBtn;
@property (weak, nonatomic) IBOutlet UITextField *inputphone;
@property (weak, nonatomic) IBOutlet UITextField *inputpasswd;
@property (weak, nonatomic) IBOutlet UIButton *announce;
@end

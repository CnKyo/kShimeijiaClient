//
//  PingjiaView.h
//  YiZanService
//
//  Created by ljg on 15-3-27.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQTextView.h"
@class IQTextView;
@interface PingjiaView : UIView
@property (weak, nonatomic) IBOutlet UIView *proView;
@property (weak, nonatomic) IBOutlet UIView *chatView;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UIButton *takePhot;
@property (weak, nonatomic) IBOutlet UIView *botView;
@property (weak, nonatomic) IBOutlet UIButton *postBtn;
@property (weak, nonatomic) IBOutlet IQTextView *textView;
@property (weak, nonatomic) IBOutlet UIView *textBaseView;
+(PingjiaView *)shareView;

@end

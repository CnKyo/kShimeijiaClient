//
//  PingjiaVC.m
//  YiZanService
//
//  Created by ljg on 15-3-27.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "PingjiaVC.h"
#import "PingjiaView.h"
#import "CTAssetsPickerController.h"

@interface PingjiaVC ()<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,CTAssetsPickerControllerDelegate>
{
    UIButton *tempProBtn;
       UIButton *tempChatBtn;
       UIButton *tempTimeBtn;
    UIButton *tempPingjiaBtn;
    NSMutableArray *allimg;
    PingjiaView *view;
}
@end

@implementation PingjiaVC
-(void)loadView
{
    self.hiddenTabBar = YES;
    [super loadView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager]setEnableAutoToolbar:YES];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mPageName = @"我的评价";
    self.Title = self.mPageName;
    allimg = [[NSMutableArray alloc]init];
    view = [PingjiaView shareView];
    view.textView.placeholder = @"想对本次服务说点什么...";
    [view.textView setHolderToTop];
//    UIButton *postBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, view.frame.size.height+10, 300, 40)];
//    [postBtn setTitle:@"发表评价" forState:UIControlStateNormal];
//    [postBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    postBtn.backgroundColor = COLOR(245, 91, 142);
//    [self.contentView addSubview:postBtn];
    [view.takePhot addTarget:self action:@selector(takePhotTouched:) forControlEvents:UIControlEventTouchUpInside];
    view.textBaseView.layer.masksToBounds = YES;
    view.textBaseView.layer.cornerRadius = 5;
    view.postBtn.layer.masksToBounds = YES;
    view.postBtn.layer.cornerRadius = 5;
    view.photoView.layer.borderColor = COLOR(232, 232, 232).CGColor;
    view.photoView.layer.borderWidth = 1;
    [self.contentView addSubview:view];
    [view.postBtn addTarget:self action:@selector(postBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    for (int i =0; i<5; i++) {
        UIButton *btn = (UIButton *)[view.proView viewWithTag:i+1];
        [btn addTarget:self action:@selector(proBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        if (i==0) {
            [btn setImage:[UIImage imageNamed:@"selectDian.png"] forState:UIControlStateNormal];
            tempProBtn = btn;

        }else
        {
            [btn setImage:[UIImage imageNamed:@"upselectDian.png"] forState:UIControlStateNormal];

        }
    }
    for (int i =0; i<5; i++) {
        UIButton *btn = (UIButton *)[view.chatView viewWithTag:i+1];
        [btn addTarget:self action:@selector(chatBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        if (i==0) {
            [btn setImage:[UIImage imageNamed:@"selectDian.png"] forState:UIControlStateNormal];
            tempChatBtn = btn;

        }else
        {
            [btn setImage:[UIImage imageNamed:@"upselectDian.png"] forState:UIControlStateNormal];

        }
    }
    for (int i =0; i<5; i++) {
        UIButton *btn = (UIButton *)[view.timeView viewWithTag:i+1];
        [btn addTarget:self action:@selector(timeBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        if (i==0) {
            [btn setImage:[UIImage imageNamed:@"selectDian.png"] forState:UIControlStateNormal];
            tempTimeBtn = btn;

        }else
        {
            [btn setImage:[UIImage imageNamed:@"upselectDian.png"] forState:UIControlStateNormal];

        }
    }
    for (int i =0; i<3; i++) {
        UIButton *btn = (UIButton *)[view.botView viewWithTag:i+1];
        [btn addTarget:self action:@selector(pingjiaBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        if (i==0) {
            [btn setImage:[UIImage imageNamed:@"selectDian.png"] forState:UIControlStateNormal];
            tempPingjiaBtn = btn;

        }else
        {
            [btn setImage:[UIImage imageNamed:@"upselectDian.png"] forState:UIControlStateNormal];

        }
    }
    self.contentView.contentSize = CGSizeMake(320, view.botView.frame.size.height +view.botView.frame.origin.y);


}
-(void)postBtnTouched:(id)sender
{
    //提交评价
    NSLog(@"专业%ld---",tempProBtn.tag);
    NSLog(@"沟通%ld---",tempChatBtn.tag);
    NSLog(@"守时%ld---",tempTimeBtn.tag);
    NSLog(@"总评%ld---",tempPingjiaBtn.tag);
    //图片 --allimg

    //内容 -- view.textView.text
    
    [_mtagOrder commentThis:view.textView.text imgs:allimg sc:(int)(6-tempProBtn.tag) cc:(int)(6-tempChatBtn.tag)  pc:(int)(6-tempTimeBtn.tag) block:^(SResBase *retobj) {
        if (retobj.msuccess) {
            [SVProgressHUD showSuccessWithStatus:retobj.mmsg];
            [self popViewController];

        }else{
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
        }
        
    }];
}
-(void)proBtnTouched:(UIButton *)sender
{
    if (sender == tempProBtn) {
        return;
    }
    [sender setImage:[UIImage imageNamed:@"selectDian.png"] forState:UIControlStateNormal];
    [tempProBtn setImage:[UIImage imageNamed:@"upselectDian.png"] forState:UIControlStateNormal];
    tempProBtn = sender;
}
-(void)chatBtnTouched:(UIButton *)sender
{
    if (sender == tempChatBtn) {
        return;
    }
    [sender setImage:[UIImage imageNamed:@"selectDian.png"] forState:UIControlStateNormal];
    [tempChatBtn setImage:[UIImage imageNamed:@"upselectDian.png"] forState:UIControlStateNormal];
    tempChatBtn = sender;
}
-(void)timeBtnTouched:(UIButton *)sender
{
    if (sender == tempTimeBtn) {
        return;
    }
    [sender setImage:[UIImage imageNamed:@"selectDian.png"] forState:UIControlStateNormal];
    [tempTimeBtn setImage:[UIImage imageNamed:@"upselectDian.png"] forState:UIControlStateNormal];
    tempTimeBtn = sender;
}
-(void)pingjiaBtnTouched:(UIButton *)sender
{
    if (sender == tempPingjiaBtn) {
        return;
    }
    [sender setImage:[UIImage imageNamed:@"selectDian.png"] forState:UIControlStateNormal];
    [tempPingjiaBtn setImage:[UIImage imageNamed:@"upselectDian.png"] forState:UIControlStateNormal];
    tempPingjiaBtn = sender;

}
-(void)takePhotTouched:(id)sender
{
    //选择图片
    if (allimg.count==3) {
        [SVProgressHUD showErrorWithStatus:@"最多只能选3张图片"];
        return;
    }
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.maximumNumberOfSelection =3-allimg.count;
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.delegate = self;

    [self presentViewController:picker animated:YES completion:NULL];

}
-(void)updatePage
{
    float x = 10.0f;
    for (int i=0; i<3; i++) {
        UIImageView *img = (UIImageView *)[view.photoView viewWithTag:20+i];
        if (img) {
            [img removeFromSuperview];
            img = nil;
        }
        UIButton *btn = (UIButton *)[view.photoView viewWithTag:10+i];
        if (btn) {
            [btn removeFromSuperview];
            btn = nil;
        }
    }
    for (int i =0; i<allimg.count; i++) {
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(x, 60, 60, 60)];
        img.tag = 20+i;
        img.image = [allimg objectAtIndex:i];
        [view.photoView addSubview:img];
        UIButton *deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(x+60, 60, 17, 17)];
        deleteBtn.tag = 10+i;
        [deleteBtn setImage:[UIImage imageNamed:@"deletimg.png"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deletePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [view.photoView addSubview:deleteBtn];
        x+=110;
    }
    UIImageView *xianimg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 49, 310, 1)];
    xianimg.backgroundColor = COLOR(232, 232, 232);
    [view.photoView addSubview:xianimg];
    CGRect rect = view.photoView.frame;
    rect.size.height = 145;
    view.photoView.frame = rect;
    rect = view.botView.frame;
    rect.origin.y = view.photoView.frame.size.height+view.photoView.frame.origin.y+10;
    view.botView.frame = rect;
    rect = view.frame;
    rect.size.height = 550;//高度拉伸
    view.frame = rect;
    self.contentView.contentSize = CGSizeMake(320, view.botView.frame.size.height +view.botView.frame.origin.y);

}
-(void)deletePhoto:(UIButton *)sender
{
    NSInteger tap = sender.tag -10;
    [allimg removeObjectAtIndex:tap];
  //  UIView *supeview = sender.superview;
    [self updatePage];
    if (allimg.count ==0) {
        CGRect rect = view.photoView.frame;
        rect.size.height = 50;
        view.photoView.frame = rect;
        rect = view.botView.frame;
        rect.origin.y = view.photoView.frame.size.height+view.photoView.frame.origin.y+10;
        view.botView.frame = rect;
        rect = view.frame;
        rect.size.height = 482;//高度还原
        view.frame = rect;
        self.contentView.contentSize = CGSizeMake(320, view.botView.frame.size.height +view.botView.frame.origin.y);
    }
}
//相册选择的
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    for (  ALAsset * one in assets  )
    {
//        ALAssetRepresentation* representation = [one defaultRepresentation];
//        CGSize dimension = [representation dimensions];
//        if( dimension.height < 100.0f && dimension.width < 100.0f )
//            t.mBigImg = t.mSmallImg;//[UIImage imageWithCGImage: [[one defaultRepresentation] fullScreenImage] ];
//        else
//            t.mBigImg = ;
//        [self reltmpCache:t];移动
        [allimg addObject:[UIImage imageWithCGImage: [[one defaultRepresentation] fullScreenImage] ]];
    }

    [self updatePage];

}

//通过相册拍照的
-(void)assetsPickerControllerDidCamera:(CTAssetsPickerController *)picker imgage:(UIImage*)image
{
    if (allimg.count<3) {
        [allimg addObject:image];
        [self updatePage];
    }
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

//
//  DatingVC.m
//  YiZanService
//
//  Created by zzl on 15/3/24.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "DatingVC.h"
#import "CunsomLabel.h"
#import "selTimeVC.h"
#import "LocVC.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "SmallSelectVC.h"
#import "ServiceVC.h"
@interface DatingVC ()<ABPeoplePickerNavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource>

@end

@implementation DatingVC
{
    NSDate*         _seledate;
    SAddress*       _seladdrObj;
    
    NSString*       _selectName;
    NSString*       _selectTel;
    
    BOOL            _bloadingcatlog;
    
    SGoodsCatLog *  _selectcatlog;
    
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
-(void)loadView
{
    self.hiddenTabBar = YES;
    [super loadView];
}
- (void)viewDidLoad {
    self.mPageName = self.mwhatFunc;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.Title = self.mwhatFunc;
    
    _minputNu.text  = [SUser currentUser].mPhone;
    _selectName     = [SUser currentUser].mUserName;
    
    [self initTimestr];
    
    _mv1.layer.cornerRadius = 3.0f;
    _mv1.layer.borderColor = [[UIColor colorWithRed:0.816 green:0.808 blue:0.800 alpha:1.000] CGColor];
    _mv1.layer.borderWidth = 0.5f;
    
    _mv2.layer.cornerRadius = 3.0f;
    _mv2.layer.borderColor = [[UIColor colorWithRed:0.816 green:0.808 blue:0.800 alpha:1.000] CGColor];
    _mv2.layer.borderWidth = 0.5f;
   
    _mcatlog.layer.cornerRadius = 3.0f;
    _mcatlog.layer.borderColor = [[UIColor colorWithRed:0.816 green:0.808 blue:0.800 alpha:1.000] CGColor];
    _mcatlog.layer.borderWidth = 0.5f;
    
    _mcatlogtableview.layer.cornerRadius = 3.0f;
    _mcatlogtableview.layer.borderColor = [[UIColor colorWithRed:0.816 green:0.808 blue:0.800 alpha:1.000] CGColor];
    _mcatlogtableview.layer.borderWidth = 0.5f;
    
    _mcatlogtableview.delegate = self;
    _mcatlogtableview.dataSource = self;
    
    
    
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addrtap:)];
    [_mseladdr addGestureRecognizer:tap];
    _mseladdr.userInteractionEnabled = YES;
    _mseladdr.verticalAlignment = VerticalAlignmentTop;
    
    _mseladdr.text = [[SUser currentUser] getDefault].mAddress;
    _seladdrObj =[[SUser currentUser] getDefault];
    if( _mseladdr.text.length == 0 )
    {
        [[SAppInfo shareClient] getUserLocation:NO block:^(NSString *err) {
            
            _mseladdr.text = [SAppInfo shareClient].mAddr;
            
            _seladdrObj = SAddress.new;
            _seladdrObj.mlat = [SAppInfo shareClient].mlat;
            _seladdrObj.mlng = [SAppInfo shareClient].mlng;
            _seladdrObj.mAddress = [SAppInfo shareClient].mAddr;
            [self updateAfterAddr];
            
        }];
    }
    
    [_mcatlogtableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    _selectcatlog = nil;
    [_mcatlog setTitle:@"加载中..." forState:UIControlStateNormal];
    _bloadingcatlog = YES;
    [SGoods getCatLog:^(SResBase *resb, NSArray *all) {
        
        _bloadingcatlog = NO;
        if( all.count )
        {
            _selectcatlog = all.firstObject;
            [_mcatlog setTitle:_selectcatlog.mName forState:UIControlStateNormal];
            [self.tempArray addObjectsFromArray:all];
        }
        else
            [_mcatlog setTitle:@"" forState:UIControlStateNormal];
    }];
    
    CGRect  f = _mwarpsc.frame;
    f.size.height = DEVICE_Height - 64;
    _mwarpsc.frame = f;
    
    _mwarpsc.contentSize = CGSizeMake(_mwarpsc.contentSize.width, 504);
    
}
-(void)initTimestr
{
    NSCalendar *greCalendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [greCalendar components:NSCalendarUnitDay|NSCalendarUnitHour fromDate:[NSDate date]];
    
    NSInteger _needToday = !(dateComponents.hour > 19);//最大是 21 点,但是,提前2小时预约,如果超过 19 点了,说明就不能要了
    
    NSInteger _todayremove= 0;
    if( _needToday )
    {//如果要今天才搞这些,否则直接从明天10点开始计算
        _todayremove = dateComponents.hour + 2 - 10;
        if( _todayremove < 0 ) _todayremove = 0;
    }
    
    NSString* nowtimestring = [Util getTimeStringHour:[NSDate date]];//2015-03-23 ??:00
    nowtimestring = [nowtimestring stringByReplacingCharactersInRange:NSMakeRange(11, 5) withString:@"%d:00:00"];//2015-03-23 10:00:00
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    _seledate = [dateFormatter dateFromString:[NSString stringWithFormat:nowtimestring,10+_todayremove]];
    _seledate = [_seledate dateByAddingTimeInterval:3600*24];
    [_mseltimebt setTitle:[Util getTimeStringHour: _seledate]   forState:UIControlStateNormal];
    
}
-(void)updateAfterAddr
{
    CGSize sss = [_mseladdr.text sizeWithFont:_mseladdr.font constrainedToSize:CGSizeMake(_mseladdr.frame.size.width, CGFLOAT_MAX)];
    CGRect f = _mseladdr.frame;
    CGFloat hhh = ceil( sss.height);
    hhh = hhh > ( _mseladdr.font.lineHeight * 3 )? (_mseladdr.font.lineHeight * 3):hhh;
    hhh = hhh < 20 ? 20:hhh;
    f.size.height = hhh;
    _mseladdr.frame = f;
    _mseladdr.verticalAlignment = VerticalAlignmentTop;
    
    f = _mv2.frame;
    f.size.height = hhh + 78;
    _mv2.frame = f;
    
    f = _marrimg.frame;
    f.origin.y = (_mv2.frame.size.height - 47 - 15)/2 + 47;
    _marrimg.frame = f;
    
    f = _mlocicon.frame;
    f.origin.y = (_mv2.frame.size.height - 47 - 15)/2 + 47;
    _mlocicon.frame = f;
    
    [Util relPosUI:_mv2 dif:45 tag:_mdatbt tagatdic:E_dic_b];
    
}
-(void)addrtap:(UITapGestureRecognizer*)sender
{
    LocVC* vc = [[LocVC alloc]init];
    vc.itblock = ^(SAddress* retobj){
        
        if( retobj )
        {
            _seladdrObj =  retobj;
            _mseladdr.text = retobj.mAddress;
            [self updateAfterAddr];
        }
        
    };
    [self pushViewController:vc];
}

- (IBAction)clicktime:(id)sender {

    [selTimeVC showSelTimeVC:self block:^(NSDate *time, NSString *str) {
        
        if( time )
        {
            [_mseltimebt setTitle:str forState:UIControlStateNormal];
            _seledate = time;
        }
        
    }];
}

- (IBAction)clickDating:(id)sender {
    
    if( _minputNu.text.length == 0 )
    {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号码"];
        return;
    }
    if( ![Util isMobileNumber:_minputNu.text] )
    {
        [SVProgressHUD showErrorWithStatus:@"请输入合法的号码"];
        return;
    }
    if( _seladdrObj  == nil )
    {
        [SVProgressHUD showErrorWithStatus:@"请选择服务地址"];
        return;
    }
    
    
    ServiceVC *vc = [[ServiceVC alloc]init];
    // vc.hiddenNavtab = YES;
    vc.datingaddr = _seladdrObj;
    vc.datingtime = _seledate;
    vc.datingName = _selectName;
    vc.datingPhone = _minputNu.text;
    vc.catlog = _selectcatlog.mId;
    
    [self pushViewController:vc];
    
}
- (IBAction)bookclicked:(id)sender {
    
    ABPeoplePickerNavigationController *viewController = [[ABPeoplePickerNavigationController alloc] init];

    viewController.peoplePickerDelegate = self;
    
    [self presentViewController:viewController animated:YES completion:^{
        
        
    }];
}

- (IBAction)catlogclicked:(id)sender {
    
    if( _bloadingcatlog ) return;
    _bloadingcatlog = YES;
    
    if( _mcatlogtableview.hidden )
    {
        _mcatlogtableview.hidden = NO;
        [UIView animateWithDuration:0.2f animations:^{
           
            CGRect f = _mcatlogtableview.frame;
            f.size.height = 178.0f;
            _mcatlogtableview.frame = f;
            
        } completion:^(BOOL finished) {
            _mtttimg.image = [UIImage imageNamed:@"jiantou_u"];
            _bloadingcatlog  = NO;
            [_mcatlogtableview reloadData];
        }];
    }
    else
    {
        
        [UIView animateWithDuration:0.2f animations:^{
            
            CGRect f = _mcatlogtableview.frame;
            f.size.height = 5.0f;
            _mcatlogtableview.frame = f;
            
        } completion:^(BOOL finished) {
            _mtttimg.image = [UIImage imageNamed:@"jiantou_d"];
            _mcatlogtableview.hidden = YES;
            _bloadingcatlog  = NO;
            [_mcatlogtableview reloadData];
        }];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tempArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    SGoodsCatLog* catlog = self.tempArray[indexPath.row];
    cell.textLabel.text = catlog.mName;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _selectcatlog = self.tempArray[indexPath.row];
    [_mcatlog setTitle:_selectcatlog.mName forState:UIControlStateNormal];
    
    [self catlogclicked:_mcatlog];
    
}

// Called after a person has been selected by the user.
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person
{
    ABMutableMultiValueRef phoneMulti = ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    if (firstName==nil) {
        firstName = @" ";
    }
    NSString *lastName=(__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (lastName==nil) {
        lastName = @" ";
    }
    _selectName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
    
    NSMutableArray *phones = NSMutableArray.new;
    for (int i = 0; i < ABMultiValueGetCount(phoneMulti); i++) {
        NSString *aPhone = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneMulti, i);
        [phones addObject:aPhone];
    }
    if( phones.count > 1 )
    {//要弹出来选择
        _selectTel = phones.lastObject;
    }
    else
    {
        _selectTel = phones.lastObject;
    }
    
    _minputNu.text = _selectTel;
    
}

// Called after a property has been selected by the user.
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    
}

// Called after the user has pressed cancel.
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    
}

// 8.0之前才会调用
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    
    return NO;
}

// 8。0之前才会调用
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    ABMutableMultiValueRef phoneMulti = ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    if (firstName==nil) {
        firstName = @" ";
    }
    NSString *lastName=(__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (lastName==nil) {
        lastName = @" ";
    }
    _selectName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
    
    NSMutableArray *phones = NSMutableArray.new;
    for (int i = 0; i < ABMultiValueGetCount(phoneMulti); i++) {
        NSString *aPhone = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneMulti, i);
        [phones addObject:aPhone];
    }
    if( phones.count > 1 )
    {//要弹出来选择
        _selectTel = phones.lastObject;
    }
    else
    {
        _selectTel = phones.lastObject;
    }
    
    _minputNu.text = _selectTel;
    
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    return NO;  
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

//
//  searchInMap.m
//  YiZanService
//
//  Created by zzl on 15/3/23.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "searchInMap.h"
#import <QMapKit/QMapKit.h>
#import "poiCell.h"
#import "APIClient.h"
@interface searchInMap ()<QMapViewDelegate, UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

@end

@implementation searchInMap
{
    UITextField* _txtf;
    QMapView* _viewmapq;
    UITableView*    _poitableview;
    
    NSArray* _alldata;
    
    BOOL    bdoing;
    BOOL    bafter;
  
    NSString*   _searchkey;
    
    
    QPointAnnotation*   _userselect;
    
    UILabel*    _seladdr;
}

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
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = NO;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}
- (void)viewDidLoad {
    self.mPageName = @"搜索POI";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    bdoing = NO;
    _viewmapq = [[QMapView alloc]initWithFrame:self.contentView.bounds];
    _viewmapq.delegate =self;
    [self.contentView addSubview:_viewmapq];
    
    NSArray* all = [[NSBundle mainBundle] loadNibNamed:@"topsearch" owner:self options:nil];
    UIView* vi = all.firstObject;
    
    vi.layer.cornerRadius = 3.0f;
    vi.layer.borderWidth = 0.5f;
    vi.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    _txtf = (UITextField*)[vi viewWithTag:99];
    [_txtf addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    
    CGRect f = vi.frame;
    f.origin.y = 23.0f;
    f.origin.x = 10.0f;
    vi.frame = f;
    [self.navBar addSubview:vi];
    
    UIButton* cancelbt = [[UIButton alloc]initWithFrame:CGRectMake(265.0f, 32.0f, 37.0f, 20.0f)];
    [cancelbt setTitle:@"取消" forState:UIControlStateNormal];
    [cancelbt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelbt.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [cancelbt addTarget:self action:@selector(cancelBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.navBar addSubview:cancelbt];
    
    
    _alldata = NSMutableArray.new;
    _poitableview = [[UITableView alloc]initWithFrame:self.contentView.bounds];
    _poitableview.delegate = self;
    _poitableview.dataSource = self;
    
    [_poitableview registerNib:[UINib nibWithNibName:@"poiCell" bundle:nil] forCellReuseIdentifier:@"poi"];
    
    
    
    _userselect = [[QPointAnnotation alloc] init];
    _userselect.title    = @"选择地址";
    _userselect.subtitle = nil;
    
    [_viewmapq addAnnotation:_userselect];
    
    all = [[NSBundle mainBundle] loadNibNamed:@"botom" owner:self options:nil];
    vi = all.firstObject;
    f = vi.frame;
    f.origin.x = 10.6f;
    f.origin.y = 406.0f;
    vi.frame = f;
    vi.layer.cornerRadius = 3.0f;
    vi.layer.borderColor = [[UIColor colorWithRed:0.820 green:0.812 blue:0.800 alpha:1.000]CGColor];
    vi.layer.borderWidth = 0.5f;
    
    _seladdr =(UILabel*) [vi viewWithTag:99];
    _seladdr.text = nil;
    
    UIButton* okbt =(UIButton*)[vi viewWithTag:88];
    [okbt addTarget:self action:@selector(okClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:vi];
    
    [self.contentView addSubview:_poitableview];
    _poitableview.hidden = YES;
    
}
-(void)okClicked:(UIButton*)sender
{
    if( _itblock )
    {
        _itblock(_userselect.subtitle,_userselect.coordinate.longitude,_userselect.coordinate.latitude);
    }
    [self cancelBtClicked:nil];
}
-(void)cancelBtClicked:(UIButton*)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _alldata.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.0f;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    poiCell* cell = [tableView dequeueReusableCellWithIdentifier:@"poi"];
    
    NSDictionary* dic = _alldata[indexPath.row];
    cell.mName.text = [dic objectForKey:@"title"];
    cell.mAddress.text = [dic objectForKey:@"address"];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_txtf resignFirstResponder];
    
    tableView.hidden = YES;
    
    NSDictionary* dic = [_alldata[indexPath.row] objectForKey:@"location"];
    [_viewmapq removeAnnotation:_userselect];
    _userselect.coordinate = CLLocationCoordinate2DMake( [[dic objectForKey:@"lat"] floatValue]  , [[dic objectForKey:@"lng"] floatValue] );
    _userselect.subtitle = [_alldata[indexPath.row] objectForKey:@"address"];
    _seladdr.text =    _userselect.subtitle;
    [self performSelector:@selector(afterdo:) withObject:nil afterDelay:0.5f];
}
-(void)afterdo:(id)sender
{
    [_viewmapq addAnnotation:_userselect];
    [_viewmapq setCenterCoordinate:_userselect.coordinate zoomLevel:15.0f animated:YES];
}
-(void)textFieldTextChange:(UITextField*)sender
{
    _searchkey = sender.text;
    [self searchKeywords:@"n"];
}

-(void)searchKeywords:(NSString*)key
{
    if( bdoing )
    {
        if( bafter ) return;
        bafter = YES;
        [self performSelector:@selector(searchKeywords:) withObject:@"a" afterDelay:1.0f];
        
    }
    
    bdoing = YES;
    
    if( [key isEqualToString:@"a"] )
        bafter = NO;
    
    if( _searchkey.length == 0 )
    {
        bdoing = NO;
        return;
    }
    _poitableview.hidden = NO;
    
    
    NSString* encodedString = [_searchkey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* requrl = [NSString stringWithFormat:@"http://apis.map.qq.com/ws/place/v1/suggestion/?keyword=%@&key=%@",encodedString,QQMAPKEY];
    [[APIClient sharedClient]GET:requrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        NSArray* tmpall = [responseObject objectForKey:@"data"];
        if( tmpall.count > 0 )
        {
            _alldata = tmpall;
            [_poitableview reloadData];
        }
        else
        {
            _alldata = nil;
            [_poitableview reloadData];
        }
        bdoing = NO;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        MLLog(@"search poi err:%@",error);
        [SVProgressHUD showErrorWithStatus:@"检索结果为空"];
        bdoing  = NO;
    }];
}


- (QAnnotationView *)mapView:(QMapView *)mapView viewForAnnotation:(id<QAnnotation>)annotation
{
    if ([annotation isKindOfClass:[QPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        QPinAnnotationView *annotationView = (QPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[QPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        
        
        annotationView.animatesDrop     = YES;
        annotationView.draggable        = NO;
        annotationView.canShowCallout   = YES;
        
        annotationView.pinColor = QPinAnnotationColorRed;
        annotationView.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return annotationView;
    }
    
    return nil;
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

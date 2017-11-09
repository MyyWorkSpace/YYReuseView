//
//  ViewController.m
//  YYReuseView
//
//  Created by HZYL_FM3 on 2017/9/8.
//  Copyright © 2017年 HZYL_FM3. All rights reserved.
//

#import "ViewController.h"
#import "YYReuseView.h"

@interface ViewController ()<YYReuseViewDataSource,YYReuseViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    YYReuseView *reuseView = [[YYReuseView alloc] initWithFrame:self.view.bounds];
    reuseView.yyDataSource = self;
    reuseView.yyDelegate = self;
    [self.view addSubview:reuseView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - YYReuseViewDataSource,YYReuseViewDelegate
- (NSInteger)yyReuseViewPageCount
{
    return 10;
}

- (NSInteger)yyReuseViewPageIndex
{
    return 0;
}

- (YYReusePageView *)yyReuseViewPageView
{
    YYReusePageView *view = [[YYReusePageView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor grayColor];
    return view;
}

- (void)yyReuseViewloadPage:(YYReusePageView *)pageView index:(NSInteger)pageIndex
{
    pageView.text = [NSString stringWithFormat:@"%ld",(long)pageIndex+1];
}

- (void)yyReuseViewTrunPageWithCount:(NSInteger)pageCount Index:(NSInteger)pageIndex
{
    
}


@end

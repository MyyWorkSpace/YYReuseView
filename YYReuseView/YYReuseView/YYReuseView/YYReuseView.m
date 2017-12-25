//
//  YYReuseView.m
//  YYReuseView
//
//  Created by HZYL_FM3 on 2017/9/8.
//  Copyright © 2017年 HZYL_FM3. All rights reserved.
//

#import "YYReuseView.h"

@interface YYReuseView ()<UIScrollViewDelegate>
{
    BOOL _calculatePageIndex; //是否计算页码
    BOOL _reloadPage; //是否刷新页面
}

@property (nonatomic, strong) UIScrollView *mainScrollView;

@property (nonatomic, strong) NSMutableSet *visiblePageViews;  //正显示的page集合
@property (nonatomic, strong) NSMutableSet *reusablePageViews; //可复用的page集合

@property (nonatomic, assign) NSUInteger pageCount;
@property (nonatomic, assign) NSUInteger pageIndex;

@end

@implementation YYReuseView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.mainScrollView];
        
        _calculatePageIndex = NO;
        _reloadPage = NO;
        self.visiblePageViews = [NSMutableSet set];
        self.reusablePageViews = [NSMutableSet set];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.yyDataSource) {
        self.pageCount = [self.yyDataSource yyReuseViewPageCount];
        self.pageIndex = [self.yyDataSource yyReuseViewPageIndex];
    }
}

#pragma mark - private
- (UIScrollView *)mainScrollView
{
    if (_mainScrollView == nil) {
        
        _mainScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _mainScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.delegate = self;
        _mainScrollView.showsVerticalScrollIndicator = NO;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        _mainScrollView.backgroundColor = [UIColor clearColor];
        _mainScrollView.bounces = NO;
        _mainScrollView.decelerationRate = 1.0;
        
        if (@available(iOS 11.0, *)) {
            _mainScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _mainScrollView;
}

- (void)setPageCount:(NSUInteger)pageCount
{
    _pageCount = pageCount;
    self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.frame.size.width * pageCount, 0);
}

- (void)setPageIndex:(NSUInteger)pageIndex
{
    _calculatePageIndex = NO;
    _pageIndex = pageIndex;
    [self.mainScrollView setContentOffset:CGPointMake(self.mainScrollView.frame.size.width * pageIndex, 0) animated:!_reloadPage];
    [self loadPage];
    
    if (self.yyDelegate && [self.yyDelegate respondsToSelector:@selector(yyReuseViewTrunPageWithCount:Index:)]) {
        [self.yyDelegate yyReuseViewTrunPageWithCount:_pageCount Index:_pageIndex];
    }
}

#pragma mark - public
- (void)reloadData
{
    _reloadPage = YES;
    
    if (self.yyDataSource && [self.yyDataSource respondsToSelector:@selector(yyReuseViewPageCount)]) {
        self.pageCount = [self.yyDataSource yyReuseViewPageCount];
    }
    if (self.yyDataSource && [self.yyDataSource respondsToSelector:@selector(yyReuseViewPageIndex)]) {
        self.pageIndex = [self.yyDataSource yyReuseViewPageIndex];
    }
}

#pragma mark - page
//加载page
- (void)loadPage
{
    [self loadPageWithIndex:_pageIndex];
    [self loadNearbyPages];
    _reloadPage = NO;
}

- (void)loadPageWithIndex:(NSUInteger)index
{
    //判断该页是否正在显示
    YYReusePageView *currentPage = [self checkPageViewIsShowWithIndex:index];
    if (currentPage) {
        if (_reloadPage) {
            //刷新执行代理方法
            if (self.yyDelegate && [self.yyDelegate respondsToSelector:@selector(yyReuseViewloadPage:index:)]) {
                [self.yyDelegate yyReuseViewloadPage:currentPage index:index];
            }
        }
        return;
    }
    
    //回收不用的page
    for (YYReusePageView *visiblePage in self.visiblePageViews) {
        if ([self checkPageViewIsFreeWithPageView:visiblePage]) {
            [self.reusablePageViews addObject:visiblePage];
            [visiblePage removeFromSuperview];
        }
    }
    //将取出来复用的page从正在显示的page集合里移除
    [self.visiblePageViews minusSet:self.reusablePageViews];
    //缓冲池中的page超过3个时，删除多余的page
    while (self.reusablePageViews.count > 2) {
        [self.reusablePageViews removeObject:[self.reusablePageViews anyObject]];
    }
    
    //从缓存池里取出page，没有则创建
    YYReusePageView *pageView = [self dequeueReusablePageView];
    if (pageView == nil) {
        if (self.yyDataSource) {
            pageView = [self.yyDataSource yyReuseViewPageView];
        }
    }
    pageView.frame = CGRectMake(index*self.mainScrollView.frame.size.width, 0, self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height);
    
    [self.mainScrollView addSubview:pageView];
    [self.visiblePageViews addObject:pageView];
    
    if (self.yyDelegate && [self.yyDelegate respondsToSelector:@selector(yyReuseViewloadPage:index:)]) {
        [self.yyDelegate yyReuseViewloadPage:pageView index:index];
    }
}

//加载pageIndex附近的page(前、后)
- (void)loadNearbyPages
{
    if (_pageIndex > 0) {
        //预加载前一个page
        [self loadPageWithIndex:_pageIndex-1];
    }
    else
    {
        //当显示第一页的时候如果第3个view正在显示，将该view加入到缓存中并移除,否则reloadData代理不会执行
        YYReusePageView *visiblePageView = [self checkPageViewIsShowWithIndex:2];
        if (visiblePageView) {
            if (self.reusablePageViews.count < 3) {
                [self.reusablePageViews addObject:visiblePageView];
            }
            [self.visiblePageViews removeObject:visiblePageView];
            [visiblePageView removeFromSuperview];
        }
    }
    
    if (_pageIndex+1 < _pageCount) {
        //预加载后一个page
        [self loadPageWithIndex:_pageIndex+1];
    }
    else
    {
        //当显示最后一页的时候如果倒数第3个view正在显示，将该view加入到缓存中并移除,否则reloadData代理不会执行
        YYReusePageView *visiblePageView = [self checkPageViewIsShowWithIndex:_pageIndex-2];
        if (visiblePageView) {
            if (self.reusablePageViews.count < 3) {
                [self.reusablePageViews addObject:visiblePageView];
            }
            [self.visiblePageViews removeObject:visiblePageView];
            [visiblePageView removeFromSuperview];
        }
    }
}

//循环利用某个page
- (YYReusePageView *)dequeueReusablePageView
{
    YYReusePageView *pageView = [self.reusablePageViews anyObject];
    if (pageView) {
        [self.reusablePageViews removeObject:pageView];
    }
    return pageView;
}

//检查page是否闲置(不在当前页、上一页、下一页的范围外就是闲置页)
- (BOOL)checkPageViewIsFreeWithPageView:(YYReusePageView *)pageView
{
    if (pageView == nil) {
        return NO;
    }
    
    int index = (int)_pageIndex;
    CGFloat x = pageView.frame.origin.x;
    CGFloat previousX = (index-1) * self.mainScrollView.frame.size.width;
    CGFloat nextX = (index+1) * self.mainScrollView.frame.size.width;
    
    if (x < previousX || x > nextX) {
        return YES;
    }
    
    return NO;
}

//检查page是否正在显示
- (YYReusePageView *)checkPageViewIsShowWithIndex:(NSUInteger)index
{
    for (YYReusePageView *pageView in self.visiblePageViews) {
        int pageIndex = pageView.frame.origin.x / self.mainScrollView.frame.size.width;
        if (pageIndex == index) {
            return pageView;
        }
    }
    return nil;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_calculatePageIndex) {
        return;
    }
    
    int page = round(scrollView.contentOffset.x / scrollView.frame.size.width);
    if (page != _pageIndex) {
        self.pageIndex = page;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    _calculatePageIndex = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _calculatePageIndex = YES;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

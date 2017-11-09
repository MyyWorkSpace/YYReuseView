//
//  YYReuseView.h
//  YYReuseView
//
//  Created by HZYL_FM3 on 2017/9/8.
//  Copyright © 2017年 HZYL_FM3. All rights reserved.
//

/*
 * by myy
 */

#import "YYReusePageView.h"

@protocol YYReuseViewDataSource,YYReuseViewDelegate;
@interface YYReuseView : UIView

@property (nonatomic, weak) id<YYReuseViewDataSource>yyDataSource;
@property (nonatomic, weak) id<YYReuseViewDelegate>yyDelegate;

- (void)reloadData;//刷新页面

@end

@protocol YYReuseViewDataSource  <NSObject>

- (NSInteger)yyReuseViewPageCount;  //总页码数
- (NSInteger)yyReuseViewPageIndex;  //当前显示的页码
- (YYReusePageView *)yyReuseViewPageView; //当前的pageView

@end

@protocol YYReuseViewDelegate <NSObject>

- (void)yyReuseViewloadPage:(YYReusePageView *)pageView index:(NSInteger)pageIndex;
- (void)yyReuseViewTrunPageWithCount:(NSInteger)pageCount Index:(NSInteger)pageIndex;

@end

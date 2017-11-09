//
//  YYReusePageView.m
//  YYReusePageView
//
//  Created by HZYL_FM3 on 2017/9/8.
//  Copyright © 2017年 HZYL_FM3. All rights reserved.
//

#import "YYReusePageView.h"

@interface YYReusePageView ()

@property (nonatomic , strong) UILabel *textLabel;

@end

@implementation YYReusePageView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor grayColor];
        
    }
    return self;
}

- (UILabel *)textLabel
{
    if (_textLabel == nil) {
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width-80)/2, (self.frame.size.height-30)/2, 80, 30)];
        textLabel.text = @"";
        textLabel.textColor = [UIColor redColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel = textLabel;
        [self addSubview:_textLabel];
    }
    return _textLabel;
}

- (void)setText:(NSString *)text
{
    self.textLabel.text = text;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

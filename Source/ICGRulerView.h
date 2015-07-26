//
//  ICGRulerView.h
//  ICGVideoTrimmer
//
//  Created by 张明瑞 on 7/15/15.
//  Copyright (c) 2015 . All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ICGRulerView : UIView

@property (assign, nonatomic) CGFloat widthPerSecond;
@property (strong, nonatomic) UIColor *themeColor;

- (instancetype)initWithFrame:(CGRect)frame widthPerSecond:(CGFloat)width themeColor:(UIColor *)color;

@end

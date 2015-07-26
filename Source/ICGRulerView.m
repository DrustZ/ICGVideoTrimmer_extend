//
//  ICGRulerView.m
//  ICGVideoTrimmer
//
//  Created by 张明瑞 on 7/15/15.
//  Copyright (c) 2015 . All rights reserved.
//


#import "ICGRulerView.h"

@implementation ICGRulerView

- (instancetype)initWithFrame:(CGRect)frame widthPerSecond:(CGFloat)width themeColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        _widthPerSecond = width;
        _themeColor = color;
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat leftMargin = 10;
    CGFloat topMargin = 0;
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat minorTickSpace = self.widthPerSecond;
    NSInteger multiple = 5;
    CGFloat majorTickLength = 12;
    CGFloat minorTickLength = 7;
    
    CGFloat baseY = topMargin + height;
    CGFloat minorY = baseY - minorTickLength;
    CGFloat majorY = baseY - majorTickLength;
    
    NSInteger step = 0;
    for (CGFloat x = leftMargin; x <= (leftMargin + width); x += minorTickSpace) {
        CGContextMoveToPoint(context, x, baseY);
        
        CGContextSetFillColorWithColor(context, self.themeColor.CGColor);
        if (step % multiple == 0) {
            CGContextFillRect(context, CGRectMake(x, majorY, 1.75, majorTickLength));
            
            UIFont *font = [UIFont systemFontOfSize:11];
            UIColor *textColor = self.themeColor;
            NSDictionary *stringAttrs = @{NSFontAttributeName:font, NSForegroundColorAttributeName:textColor};
            
            NSInteger minutes = step / 60;
            NSInteger seconds = step % 60;
            
            NSAttributedString* attrStr;
            
            if (minutes > 0) {
                attrStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld:%02ld", (long) minutes, (long) seconds] attributes:stringAttrs];
            }
            else {
                attrStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@":%02ld", (long) seconds] attributes:stringAttrs];
            }
            
            [attrStr drawAtPoint:CGPointMake(x-7, majorY - 15)];
            
            
        } else {
            CGContextFillRect(context, CGRectMake(x, minorY, 1.0, minorTickLength));
        }
        
        step++;
    }
    
}

@end

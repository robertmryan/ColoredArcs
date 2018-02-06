//
//  ColoredArc.h
//  ColoredArcsKit
//
//  Created by Robert Ryan on 2/6/18.
//  Copyright © 2018 Robert Ryan. All rights reserved.
//

@import UIKit;

@interface ColoredArc : NSObject

@property (nonatomic) CGFloat start;
@property (nonatomic) CGFloat end;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic) CAShapeLayer *shapeLayer;

- (instancetype)initWithStart:(CGFloat)start end:(CGFloat)end color:(UIColor *)color;

@end

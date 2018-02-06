//
//  ColoredArc.m
//  ColoredArcsKit
//
//  Created by Robert Ryan on 2/6/18.
//  Copyright © 2018 Robert Ryan. All rights reserved.
//

#import "ColoredArc.h"

@implementation ColoredArc

- (instancetype)initWithStart:(CGFloat)start end:(CGFloat)end color:(UIColor *)color {
    self = [super init];
    if (self) {
        _start = start;
        _end = end;
        _color = color;
    }
    return self;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    _shapeLayer.strokeColor = color.CGColor;
}

@end

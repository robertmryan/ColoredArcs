//
//  ColoredArcView.m
//  ColoredArcsKit
//
//  Created by Robert Ryan on 2/5/18.
//  Copyright © 2018 Robert Ryan. All rights reserved.
//

#import "ColoredArcView.h"
#import "ColoredArc.h"

@interface ColoredArcView ()

@property (nonatomic, weak) CAShapeLayer *innerBoundaryLayer;
@property (nonatomic, weak) CAShapeLayer *outerBoundaryLayer;
@property (nonatomic, strong) NSMutableArray <ColoredArc *> *arcs;
@property (nonatomic, strong) ColoredArc *selectedArc;

@end

@implementation ColoredArcView

// The various init methods all just call `configure`.

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

/**
 Configure the view.
 
 Adds the various shape layers and initializes the arcs.
 */

- (void)configure {
    self.arcWidth = 20;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth = 0.5;
    shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:shapeLayer];
    self.innerBoundaryLayer = shapeLayer;
    
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth = 0.5;
    shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:shapeLayer];
    self.outerBoundaryLayer = shapeLayer;
    
    self.arcs = [NSMutableArray array];
    
    [self.arcs addObject:[[ColoredArc alloc] initWithStart:4  end:6  color:[UIColor greenColor]]];
    [self.arcs addObject:[[ColoredArc alloc] initWithStart:11 end:13 color:[UIColor greenColor]]];
    [self.arcs addObject:[[ColoredArc alloc] initWithStart:19 end:22 color:[UIColor greenColor]]];
    
    for (ColoredArc *arc in self.arcs) {
        shapeLayer = [CAShapeLayer layer];
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.strokeColor = arc.color.CGColor;
        shapeLayer.lineWidth = self.arcWidth;
        shapeLayer.lineCap = kCALineCapRound;
        [self.layer addSublayer:shapeLayer];
        arc.shapeLayer = shapeLayer;
    }
}

/**
 Calculate the value from the angle. This assumes that 0 starts at 12 o'clock
 and proceeds clockwise.
 
 This is used for translating a tapped location on the view into a numeric value.

 @param value The value for which the angle must be determined.
 
 @return The resulting value.
 */

- (CGFloat)angleForValue:(CGFloat)value {
    return -M_PI_2 + M_PI * 2.0 * value / 24.0;
}

/**
 Calculate the value 0-23 based upon the angle. This assumes that 0 starts at 12 o'clock
 and proceeds clockwise.
 
 This is used for rendering the arcs.

 @param angle The angle between the center of the arcs and the point in consideration.

 @return The resulting "value", 0-23.
 */

- (CGFloat)valueForAngle:(CGFloat)angle {
    angle += M_PI_2;
    if (angle < 0)        angle += M_PI * 2;
    if (angle > M_PI * 2) angle -= M_PI * 2;
    return angle * 24.0 / (M_PI * 2.0);
}

/**
 The center of the arcs given the current view dimensions.

 @return The center of the arcs.
 */

- (CGPoint)arcCenter {
    return CGPointMake(self.bounds.origin.x + self.bounds.size.width / 2,
                       self.bounds.origin.y + self.bounds.size.height / 2);
}

/**
 The radius of the arcs given the current view dimensions.

 @return The radius of the arcs.
 */

- (CGFloat)arcRadius {
    CGRect rect = CGRectInset(self.bounds, 0.5, 0.5);
    
    return (MIN(rect.size.height, rect.size.width) - self.arcWidth) / 2;
}

// Update the paths when the boundaries change

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat radius = [self arcRadius];
    CGPoint center = [self arcCenter];
    
    self.innerBoundaryLayer.path = [UIBezierPath bezierPathWithArcCenter:center
                                                                  radius:radius - self.arcWidth / 2 - 0.5
                                                              startAngle:0
                                                                endAngle:M_PI * 2
                                                               clockwise:true].CGPath;
    
    self.outerBoundaryLayer.path = [UIBezierPath bezierPathWithArcCenter:center
                                                                  radius:radius + self.arcWidth / 2 + 0.5
                                                              startAngle:0
                                                                endAngle:M_PI * 2
                                                               clockwise:true].CGPath;
    
    for (ColoredArc *arc in self.arcs) {
        arc.shapeLayer.path = [UIBezierPath bezierPathWithArcCenter:center
                                                             radius:radius
                                                         startAngle:[self angleForValue:arc.start]
                                                           endAngle:[self angleForValue:arc.end]
                                                          clockwise:true].CGPath;
    }
}

/**
 Given a particular location on the screen, identify which ARC this is inside.
 
 This is just looking at the relative angle of the point to the center of the circle, and
 then comparing that to the start and end angles of the various arcs. So, this is really
 just checking to angles. You might want to check distance, too, depending upon the desired
 UX.
 
 Note, you really want something more generous than this (to allow taps very near an arc),
 but given that this is a simple demo, I'll leave this to the reader.

 @param location The CGPoint we're considering
 
 @return The ColoredArc within which that CGPoint falls.
 */

- (ColoredArc *)arcForPoint:(CGPoint)location {
    CGPoint center = [self arcCenter];
    CGFloat angle = atan2(location.y - center.y, location.x - center.x);
    CGFloat value = [self valueForAngle:angle];

    for (ColoredArc *arc in self.arcs) {
        if (arc.start < arc.end) {
            if (arc.start <= value && arc.end >= value) {
                return arc;
            }
        } else {
            if (arc.start <= value || value <= arc.end) {
                return arc;
            }
        }
    }
    
    return nil;
}

// When touches begins, see which arc the touch falls within

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint location = [[touches anyObject] locationInView:self];
    
    self.selectedArc = [self arcForPoint:location];
    
    if (!self.selectedArc) {
        [super touchesBegan:touches withEvent:event];
    }
}

// When the touch moves, see how distance from center varies and update UI accordingly.

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // if we didn't start in arc, let's ignore this
    
    if (!self.selectedArc) {
        [super touchesMoved:touches withEvent:event];
        return;
    }
    
    // might as well use predictive touches for more responsive UI
    
    UITouch *touch = [touches anyObject];
    UITouch *predicted = [[event predictedTouchesForTouch:touch] lastObject];
    if (predicted) {
        touch = predicted;
    }
    
    [self updateColorForPoint:[touch locationInView:self]];
}

// When the touch ends, see how distance from center varies and update UI accordingly.

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.selectedArc) {
        [super touchesEnded:touches withEvent:event];
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    [self updateColorForPoint:[touch locationInView:self]];
}

/**
 Update the color of the selectedArc based upon CGPoint value.

 @param location The CGPoint used to update color.
 */

- (void)updateColorForPoint:(CGPoint)location {
    // figure out the distance from center and compare to radius
    
    CGPoint center = [self arcCenter];
    CGFloat distance = hypotf(center.x - location.x, center.y - location.y);
    CGFloat radius = [self arcRadius];
    
    // use whatever criteria you want here
    
    if (distance <= (radius - self.arcWidth / 2) - 45) {
        self.selectedArc.color = [UIColor blueColor];
    } else if (distance <= (radius + self.arcWidth / 2) + 15) {
        self.selectedArc.color = [UIColor greenColor];
    } else {
        self.selectedArc.color = [UIColor redColor];
    }
}

@end

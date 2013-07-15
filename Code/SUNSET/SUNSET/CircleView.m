//
//  DonutView.m
//  SUNSET
//
//  Created by Lindemann on 08.07.13.
//  Copyright (c) 2013 Lindemann. All rights reserved.
//

/* Math Helper Functions */
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )


#import "CircleView.h"
#import "AppDelegate.h"
#import "SunFacts.h"

@interface CircleView () <SunFactsDelegate>

@property (nonatomic, strong) NSMutableArray *sequenceOfAnimations;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) SunFacts *sunFacts;
@property (nonatomic) float arcRepresentationOfSunlight;

@end

@implementation CircleView

/*/////////////////////////////////////////////////////*/
/*                       LIFECYCLE                     */
/*/////////////////////////////////////////////////////*/

- (id)initWithSuperView:(UIView*)superView {
    self = [super init];
    if (self) {
        int widht = MIN(superView.frame.size.width, superView.frame.size.height);
        int height = widht;
        int x = superView.frame.size.width / 2;
        int y = superView.frame.size.height / 2;
        self.frame = CGRectMake(x - widht / 2, y - height / 2, widht, height);

        self.sequenceOfAnimations = [NSMutableArray new];
        
        // First animation became started in AppDelegate
//        [self startAnimation];
//        [self lauchAnimation];
        
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
        [self.tapGestureRecognizer setNumberOfTapsRequired:1];
        self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        self.sunFacts = [SunFacts new];
        self.sunFacts.delegate = self;
    }
    return self;
}

/*/////////////////////////////////////////////////////*/
/*                   ANIMATION CHAINS                  */
/*/////////////////////////////////////////////////////*/
#pragma mark - Animation Chains

- (void)viewDidBecomeActive {
    [self.sunFacts.locationManager startUpdatingLocation];
}

- (void)lauchAnimation {
    [self removeGestureRecognizer:self.tapGestureRecognizer];
    
    [self clearView];
    [self pushBreakAnimationWithDuration:1 ForAnimationSequence:self.sequenceOfAnimations];
    
    [self pushPulsingEllipseAnimationWithRepeatCoutn:2];
    [self pushScalingArcAnimationInverse:NO];
    [self pushStrokeEndOfArcAnimationInverse:NO Color:self.appDelegate.colorScheme.accentColor StrokeEnd:self.arcRepresentationOfSunlight];
    
    // Start the chain of animations by adding the "next" (the first) animation
    [self applyNextAnimation];
}

- (void)pushStrokeEndOfArcAnimationInverse:(BOOL)inverse Color:(UIColor*)color StrokeEnd:(float)strokeEnd {
    int lineWidth = self.frame.size.width * 0.06;
    int parentLineWidth = self.frame.size.width * 0.1;
    int realRadius = ((self.frame.size.width * 0.9) / 2);
    int radius = realRadius - parentLineWidth  / 2;
    float duration = 1.4;
    
    CAShapeLayer *layer = [self arcLayerWithRdius:radius StrokeColor:color LineWidth:lineWidth StrokeStart:0 StrokeEnd:0];
    [self.layer addSublayer:layer];
    
    // rotate begin of arc from 270° to somewhere on the left side, with 270° as the center
    int offset = (360 * strokeEnd) / 2;
    layer.transform = CATransform3DMakeRotation(ToRad(-offset), 0.0, 0.0, 1.0);
    
    CABasicAnimation *animation = [self strokeEndAnimationWithDuration:duration FromValue:0 ToValue:strokeEnd];
    if (inverse) {
        animation = [self scaleAnimationWithDuration:duration FromValue:strokeEnd ToValue:0];
    }
    [animation setValue:layer forKey:@"layerToApplyAnimationTo"];
    [self.sequenceOfAnimations addObject:animation];
}

- (void)pushScalingArcAnimationInverse:(BOOL)inverse {
    int lineWidth = self.frame.size.width * 0.1;
    int realRadius = ((self.frame.size.width * 0.9) / 2);
    int radius = realRadius - lineWidth / 2;
    float duration = 1;
    
    CAShapeLayer *layer = [self arcLayerWithRdius:radius StrokeColor:self.appDelegate.colorScheme.secondaryColor LineWidth:lineWidth StrokeStart:0 StrokeEnd:1];
    [self.layer addSublayer:layer];
    layer.transform = CATransform3DMakeScale(0, 0, 1);
    
    CABasicAnimation *animation = [self scaleAnimationWithDuration:duration FromValue:0 ToValue:1];
    if (inverse) {
        animation = [self scaleAnimationWithDuration:duration FromValue:1 ToValue:0];
    }
    [animation setValue:layer forKey:@"layerToApplyAnimationTo"];
    [self.sequenceOfAnimations addObject:animation];
}

- (void)pushPulsingEllipseAnimationWithRepeatCoutn:(int)repeatCount {
    NSMutableArray *circleSequenceOfAnimations = [NSMutableArray new];
    
    UIColor *accentColor = self.appDelegate.colorScheme.accentColor;
    UIColor *mainColor = self.appDelegate.colorScheme.mainColor;
    UIColor *middleColor = [self colorLerpFrom:accentColor to:mainColor withDuration:0.33];
    UIColor *outerColor = [self colorLerpFrom:accentColor to:mainColor withDuration:0.66];
    
    float circleAnimationDuration = 0.2;
    
    CAShapeLayer *outerCircle = [self ellipseLayerWithRadius:(self.frame.size.width * 0.9) / 2 Color:mainColor];
    [self.layer addSublayer:outerCircle];
    
    CAShapeLayer *middleCircle = [self ellipseLayerWithRadius:(self.frame.size.width * 0.7) / 2 Color:mainColor];
    [self.layer addSublayer:middleCircle];
    
    CAShapeLayer *innerCircle = [self ellipseLayerWithRadius:(self.frame.size.width * 0.5) / 2 Color:mainColor];
    [self.layer addSublayer:innerCircle];
    
    // Adding the circles
    CABasicAnimation *animation01 = [self fillColorAnimationWithDuration:circleAnimationDuration FromValue:mainColor ToValue:accentColor];
    [animation01 setValue:innerCircle forKey:@"layerToApplyAnimationTo"];
    [circleSequenceOfAnimations addObject:animation01];
    
    CABasicAnimation *animation02 = [self fillColorAnimationWithDuration:circleAnimationDuration FromValue:mainColor ToValue:middleColor];
    [animation02 setValue:middleCircle forKey:@"layerToApplyAnimationTo"];
    [circleSequenceOfAnimations addObject:animation02];
    
    CABasicAnimation *animation03 = [self fillColorAnimationWithDuration:circleAnimationDuration FromValue:mainColor ToValue:outerColor];
    [animation03 setValue:outerCircle forKey:@"layerToApplyAnimationTo"];
    [circleSequenceOfAnimations addObject:animation03];
    
    // Removing the circles
    CABasicAnimation *animation04 = [self fillColorAnimationWithDuration:circleAnimationDuration FromValue:accentColor ToValue:mainColor];
    [animation04 setValue:innerCircle forKey:@"layerToApplyAnimationTo"];
    [circleSequenceOfAnimations addObject:animation04];
    
    CABasicAnimation *animation05 = [self fillColorAnimationWithDuration:circleAnimationDuration FromValue:middleColor ToValue:mainColor];
    [animation05 setValue:middleCircle forKey:@"layerToApplyAnimationTo"];
    [circleSequenceOfAnimations addObject:animation05];
    
    CABasicAnimation *animation06 = [self fillColorAnimationWithDuration:circleAnimationDuration FromValue:outerColor ToValue:mainColor];
    [animation06 setValue:outerCircle forKey:@"layerToApplyAnimationTo"];
    [circleSequenceOfAnimations addObject:animation06];
    
    // Short Break - Invisable animation goes from mainColor to mainColor
    [self pushBreakAnimationWithDuration:circleAnimationDuration ForAnimationSequence:circleSequenceOfAnimations];
    
    for (int i = 0; i < repeatCount; ++i) {
        [self.sequenceOfAnimations addObjectsFromArray:circleSequenceOfAnimations];
    }
}

- (void)pushBreakAnimationWithDuration:(float)duration ForAnimationSequence:(NSMutableArray*)animationSequence {
    CABasicAnimation *animationBreak = [self fillColorAnimationWithDuration:duration FromValue:self.appDelegate.colorScheme.mainColor ToValue:self.appDelegate.colorScheme.mainColor];
    [animationBreak setValue:self.layer forKey:@"layerToApplyAnimationTo"];
    [animationSequence addObject:animationBreak];
}

/*/////////////////////////////////////////////////////*/
/*                PATHES + LAYERS + Labels             */
/*/////////////////////////////////////////////////////*/
#pragma mark - Pathes, Layers, Labels

- (CAShapeLayer*)ellipseLayerWithRadius:(int)radius Color:(UIColor*)color {
    CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2));
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path;
    CGPathRelease(path);
    shapeLayer.fillColor = color.CGColor;
    return  shapeLayer;
}

- (CAShapeLayer*)arcLayerWithRdius:(int)radius StrokeColor:(UIColor*)strokColor LineWidth:(int)lineWitdh StrokeStart:(float)strokeStart StrokeEnd:(float)strokeEnd {
    
    int x = self.frame.size.width / 2;
    int y = self.frame.size.height / 2;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, x, y, radius,  (3 * M_PI) / 2, - M_PI / 2, NO);
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    shapeLayer.path = path;
    CGPathRelease(path);
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    shapeLayer.strokeColor = strokColor.CGColor;
    shapeLayer.strokeStart = strokeStart;
    shapeLayer.strokeEnd = strokeEnd;
    shapeLayer.lineWidth = lineWitdh;
    shapeLayer.lineCap = kCALineCapRound;
    return shapeLayer;
}

- (void)addTimeLabel {
    NSString *string = self.sunFacts.timeTillSunset;
    if (self.sunFacts.daytime == NIGHT) {
        string = [NSString stringWithFormat:@"-%@", self.sunFacts.timeTillSunrise];
    }
        
    self.timeLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.timeLabel.text = string;
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.textColor = self.appDelegate.colorScheme.fontColor;

    CGRect frame = CGRectMake(0, 0, self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    self.timeLabel.frame = frame;
    self.timeLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);

    int fontSize = [self maximalSystemFontSizeOfString:string ForRect:frame];
    self.timeLabel.font = [UIFont systemFontOfSize:fontSize];
    
    self.timeLabel.alpha = 0;
    [self addSubview:self.timeLabel];
    
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.timeLabel.alpha = 1;
    } completion:^(BOOL finished) {
        [self addGestureRecognizer:self.tapGestureRecognizer];
    }];
}

/*/////////////////////////////////////////////////////*/
/*                 BASIC ANIMATIONS                    */
/*/////////////////////////////////////////////////////*/
#pragma mark - Basic Animations

- (CABasicAnimation*)scaleAnimationWithDuration:(CFTimeInterval)duration FromValue:(float)fromValue ToValue:(float)toValue {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(fromValue, fromValue, 1)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(toValue, toValue, 1)];
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut];
    animation.duration = duration;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    return  animation;
}

- (CABasicAnimation*)fillColorAnimationWithDuration:(CFTimeInterval)duration FromValue:(UIColor*)fromValue ToValue:(UIColor*)toValue {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    animation.fromValue = (__bridge id)(fromValue.CGColor);
    animation.toValue = (__bridge id)(toValue.CGColor);
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn];
    animation.duration = duration;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    return  animation;
}

- (CABasicAnimation*)strokeEndAnimationWithDuration:(CFTimeInterval)duration FromValue:(float)fromValue ToValue:(float)toValue {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = [NSNumber numberWithFloat:fromValue];
    animation.toValue = [NSNumber numberWithFloat:toValue];
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut];
    animation.duration = duration;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    return  animation;
}

/*/////////////////////////////////////////////////////*/
/*                     LITLE HELPER                    */
/*/////////////////////////////////////////////////////*/
#pragma mark - Helper

- (UIColor *)colorLerpFrom:(UIColor *)start to:(UIColor *)end withDuration:(float)t {
    // Source: http://nial.me/2013/06/linearly-interpolating-between-two-uicolors
    if(t < 0.0f) t = 0.0f;
    if(t > 1.0f) t = 1.0f;
    
    const CGFloat *startComponent = CGColorGetComponents(start.CGColor);
    const CGFloat *endComponent = CGColorGetComponents(end.CGColor);
    
    float startAlpha = CGColorGetAlpha(start.CGColor);
    float endAlpha = CGColorGetAlpha(end.CGColor);
    
    float r = startComponent[0] + (endComponent[0] - startComponent[0]) * t;
    float g = startComponent[1] + (endComponent[1] - startComponent[1]) * t;
    float b = startComponent[2] + (endComponent[2] - startComponent[2]) * t;
    float a = startAlpha + (endAlpha - startAlpha) * t;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

- (void)clearView {
    [self.timeLabel removeFromSuperview];
    self.timeLabel = nil;
    for (CALayer *layer in self.layer.sublayers) {
        [layer removeAllAnimations];
    }
    self.layer.sublayers = nil;
}

- (void)handleTap {
    [self clearView];
//    [self mainAnimation];
    [self.sunFacts.locationManager startUpdatingLocation];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {
    [self applyNextAnimation];
}

- (void)applyNextAnimation {
    // Finish when there are no more animations to run
    if ([[self sequenceOfAnimations] count] == 0) {
        [self addTimeLabel];
//        [self addGestureRecognizer:self.tapGestureRecognizer];
        return;
    }
    
    // Get the next animation and remove it from the "queue"
    CABasicAnimation * nextAnimation = [[self sequenceOfAnimations] objectAtIndex:0];
    [[self sequenceOfAnimations] removeObjectAtIndex:0];
    
    // Get the layer and apply the animation
    CALayer *layerToAnimate = [nextAnimation valueForKey:@"layerToApplyAnimationTo"];
    [layerToAnimate addAnimation:nextAnimation forKey:nil];
}

- (int)maximalSystemFontSizeOfString:(NSString*)string ForRect:(CGRect)rect {
    int fontSize = 1;
    CGSize stringSize = [string sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]}];
    while (stringSize.width < rect.size.width ) {
        ++fontSize;
        stringSize = [string sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]}];
    }
    return fontSize - 1;
}

/*/////////////////////////////////////////////////////*/
/*                  SUNFACTS DELEGATE                  */
/*/////////////////////////////////////////////////////*/
#pragma mark - SunFacts Delegate

- (void)sunFactsDidUpdateData {
    if (self.sunFacts.daytime == DAY) {
        int secondsOfADay = 60 * 60 * 24;
        self.arcRepresentationOfSunlight = (float)self.sunFacts.secondsTillSunset / secondsOfADay;
    } else {
        self.arcRepresentationOfSunlight = 0;
    }
    [self lauchAnimation];
}

- (void)sunFactsDidFail {
    NSLog(@"Fail");
}

@end

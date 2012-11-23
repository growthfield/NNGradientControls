
#import "NNGradientSlideButton.h"
#import "NNGradientControls.h"
#import "NNGradientLusterLayer.h"
#import <QuartzCore/QuartzCore.h>

#define FRAMES_PER_SEC 8

#define P(x, y) CGPointMake(x, y)
#define SIZE(array) (sizeof(array)/sizeof(array[0]))


@interface NNGradientArrowLayer : CALayer
@end

@implementation NNGradientArrowLayer

- (void)drawInContext:(CGContextRef)context
{
    [self drawArrowPath:context];
}

- (void)drawArrowPath:(CGContextRef)context {

    CGFloat barWidth = self.bounds.size.width * 0.25;
    CGFloat barHeight = self.bounds.size.height * 0.25;
    CGFloat headHeight = self.bounds.size.height * 0.75;
    CGFloat margin = self.bounds.size.width * 0.25;
    CGFloat baseY = self.bounds.size.height / 2;
    
    // arrow
    CGPoint p[8];
    NSInteger i = 0;
    p[i++] = P(margin, baseY);
    p[i++] = P(margin, baseY + barHeight / 2);
    p[i++] = P(margin + barWidth, baseY + barHeight / 2);
    p[i++] = P(margin + barWidth, baseY + headHeight / 2);
    p[i++] = P(self.bounds.size.width - margin, baseY);
    p[i++] = P(margin + barWidth, baseY - headHeight / 2);
    p[i++] = P(margin + barWidth, baseY - barHeight / 2);
    p[i++] = P(margin, baseY - barHeight / 2);
    CGContextAddLines(context, p, SIZE(p));
    CGContextSetFillColorWithColor(context, CGWHITE(0.0, 0.5));
    CGContextFillPath(context);

    // edge
    void (^line)(CGPoint p1, CGPoint p2, CGFloat, CGColorRef) = ^(CGPoint p1, CGPoint p2, CGFloat width, CGColorRef color) {
        CGPoint p[2] = {p1, p2};
        CGContextAddLines(context, p, 2);
        CGContextSetStrokeColorWithColor(context, color);
        CGContextSetLineWidth(context, width);
        CGContextStrokePath(context);
    };
    line(P(margin, baseY - barHeight / 2),P(margin, baseY - barHeight / 2), 0.2, CGWHITE(1.0, 1.0));
    line(P(margin, baseY + barHeight / 2), P(margin + barWidth, baseY + barHeight / 2), 0.3, CGWHITE(1.0, 1.0));
    line(P(margin + barWidth, baseY + barHeight / 2), P(margin + barWidth, baseY + headHeight / 2), 0.2, CGWHITE(1.0, 1.0));
    line(P(margin + barWidth, baseY + headHeight / 2), P(self.bounds.size.width - margin, baseY), 0.3, CGWHITE(1.0, 1.0));
    line(P(self.bounds.size.width - margin - 1, baseY), P(margin + barWidth, baseY - headHeight / 2 + 1), 0.4, CGWHITE(0.0, 1.0));
    line(P(margin + barWidth, baseY - headHeight / 2), P(margin + barWidth, baseY - barHeight / 2), 0.4, CGWHITE(0.0, 1.0));
    line(P(margin, baseY - barHeight / 2), P(margin + barWidth, baseY - barHeight / 2), 0.4, CGWHITE(0.0, 1.0));
    
    return;
}

@end


@interface NNGradientSlideButton() {
    CGFloat locations[3];
}

@property(nonatomic) CALayer* baseLayer;
@property(nonatomic) CALayer* bezelLayer;
@property(nonatomic) CAGradientLayer* bezelBackgroundGraidentLayer;
@property(nonatomic) CALayer* buttonLayer;
@property(nonatomic) CAGradientLayer* normalGradientLayer;
@property(nonatomic) CALayer* lusterLayer;
@property(nonatomic) CALayer* arrowLayer;
@property(nonatomic) CALayer* textLayer;
@property(nonatomic) NSTimer* gradientTimer;
@property(nonatomic) NSUInteger gradientCount;
@property(nonatomic) BOOL sliding;
@property(nonatomic) CGPoint btnBasePoint;
@property(nonatomic) CGFloat btnBaseRightTopInView;
@property(nonatomic) CGFloat btnBaseLeftTopInView;
@property(nonatomic) CGFloat btnMaxRightTopInView;
@property(nonatomic) CGFloat touchBtnXDiff;

@end

@implementation NNGradientSlideButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return self;
    }
    self.contentScaleFactor = 2.0;
    
    // Setting defaults
    self.leftPadding = 0;
    self.rightPadding = 0;
    self.font = [UIFont systemFontOfSize:24];
    self.textColor = [UIColor whiteColor];
    self.text = @"Slide to do!!";
    CGFloat scale = [UIScreen mainScreen].scale;
    
    UIColor* bgColor = self.backgroundColor;
    self.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    self.baseLayer = [CALayer layer];
    self.baseLayer.cornerRadius = BEZEL_CORNER_RADIUS;
    self.baseLayer.backgroundColor = CGWHITE(0.5, 1.0);
    self.baseLayer.masksToBounds = YES;
    [self.layer addSublayer:self.baseLayer];
    
    self.bezelLayer = [CALayer layer];
    self.bezelLayer.cornerRadius = BEZEL_CORNER_RADIUS;
    self.bezelLayer.backgroundColor = CGWHITE(0.1, 1.0);
    self.bezelLayer.masksToBounds = YES;
    [self.baseLayer addSublayer:self.bezelLayer];
    self.bezelBackgroundGraidentLayer = [self createBezelBackgroundGradientLayer];
    self.bezelBackgroundGraidentLayer.cornerRadius = BEZEL_CORNER_RADIUS;
    [self.bezelLayer addSublayer:self.bezelBackgroundGraidentLayer];
    
    self.textLayer = [CALayer layer];
    self.textLayer.contentsScale = scale;
    self.textLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.textLayer.delegate = self;
    [self.bezelLayer addSublayer:self.textLayer];
    [self.textLayer setNeedsDisplay];
    
    self.buttonLayer = [CALayer layer];
    self.buttonLayer.backgroundColor = bgColor.CGColor;
    self.buttonLayer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.buttonLayer.masksToBounds = YES;
    self.buttonLayer.anchorPoint = CGPointMake(1.0, 1.0);
    [self.bezelLayer addSublayer:self.buttonLayer];

    self.arrowLayer = [NNGradientArrowLayer layer];
    self.arrowLayer.contentsScale = 2.0;
    [self.buttonLayer addSublayer:self.arrowLayer];
    [self.arrowLayer setNeedsDisplay];
    
    self.normalGradientLayer = [self createSlideButtonGradientLayer];
    [self.buttonLayer addSublayer:self.normalGradientLayer];
    
    self.lusterLayer = [NNGradientLusterLayer layer];
    [self.buttonLayer addSublayer:self.lusterLayer];
    [self.lusterLayer setNeedsDisplay];

    [self startTextGradientAnimation];
    
    return self;
}

- (void)dealloc
{
    [self stopTextGradientAnimation];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect b = self.bounds;
    b.size.width -= self.leftPadding + self.rightPadding;
    b.origin.x = self.leftPadding;
    self.baseLayer.frame = b;
    
    b = self.baseLayer.bounds;
    b.size.height -= BEZEL_WIDTH * 2 + BEZEL_ADDITIONAL_BOTTOM_SIZE;
    b.size.width -= BEZEL_WIDTH * 2;
    b.origin.x = BEZEL_WIDTH;
    b.origin.y = BEZEL_WIDTH;
    self.bezelLayer.frame = b;
    self.bezelBackgroundGraidentLayer.frame = self.bezelLayer.bounds;
    
    b = self.bezelLayer.bounds;
    b.size.height -= BUTTON_MARGIN * 2 - BEZEL_ADDITIONAL_BOTTOM_SIZE;
    CGFloat w = b.size.width - BUTTON_MARGIN * 2;
    w /= 4;
    b.size.width = w;
    b.origin.x = BUTTON_MARGIN;
    b.origin.y = BUTTON_MARGIN;
    self.buttonLayer.frame = b;
    self.arrowLayer.frame = self.buttonLayer.bounds;
    
    CGSize textSize = [self.text sizeWithFont:self.font];
    CGFloat x = (self.bezelLayer.bounds.size.width - textSize.width - self.buttonLayer.bounds.size.width) / 2;
    x += self.buttonLayer.bounds.size.width;
    CGFloat y = (self.bezelLayer.bounds.size.height - textSize.height) / 2;
    self.textLayer.frame = CGRectMake(x, y, textSize.width, textSize.height);
    
    self.normalGradientLayer.frame = self.buttonLayer.bounds;
    self.lusterLayer.frame = CGRectInset(self.buttonLayer.bounds, 0.5, 1.0);

    self.btnBasePoint = self.buttonLayer.position;
    self.btnBaseRightTopInView = [self.layer convertPoint:self.btnBasePoint fromLayer:self.buttonLayer].x;
    self.btnBaseLeftTopInView = self.btnBaseRightTopInView - self.buttonLayer.frame.size.width;
    self.btnMaxRightTopInView = self.bezelLayer.frame.size.width - BUTTON_MARGIN;
}

- (CAGradientLayer*)createSlideButtonGradientLayer
{
    CAGradientLayer* gl = [CAGradientLayer layer];
    gl.locations = @[@0.0, @0.5, @0.5, @1.0];
    gl.colors = @[(id)CGWHITE(1.0, 0.7), (id)CGWHITE(1.0, 0.4), (id)CGWHITE(1.0, 0.3), (id)CGWHITE(1.0, 0.0)];
    return gl;
}

- (CAGradientLayer*) createBezelBackgroundGradientLayer
{
    CAGradientLayer* gl = [CAGradientLayer layer];
    gl.locations = @[@0.0, @0.95, @1.0];
    gl.colors = @[(id)CGWHITE(0.0, 1.0), (id)CGWHITE(0.2, 1.0), (id)CGWHITE(0.2, 1.0)];
    return gl;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    UIFont* font = self.font;
    const char* fontName = font.fontName.UTF8String;
    CGFloat size = font.pointSize;
    CGContextSelectFont(ctx, fontName, size, kCGEncodingMacRoman);
    CGAffineTransform affine = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
    CGContextSetTextMatrix(ctx, affine);
    CGContextSetTextDrawingMode(ctx, kCGTextClip);
    const char* text = [self.text cStringUsingEncoding:NSMacOSRomanStringEncoding];
    CGContextShowTextAtPoint(ctx, 0, font.ascender, text, strlen(text));
    CGPoint end = CGContextGetTextPosition(ctx);

    UIColor* color = self.textColor;
    CGFloat red = 1.0;
    CGFloat green = 1.0;
    CGFloat blue = 1.0;
    CGFloat alpha = 1.0;
    if (![color getRed:&red green:&green blue:&blue alpha:&alpha]) {
        [color getWhite:&red alpha:&alpha];
        green = blue = red;
    }
    size_t numOfLocations = 3;
    CGFloat components[12];
    for (int i=0; i<numOfLocations; i++) {
        int idx = i * 4;
        components[idx++] = red;
        components[idx++] = green;
        components[idx++] = blue;
        components[idx++] = alpha * 0.3;
    }
    if (self.gradientTimer) {
        components[7] = alpha;
    }
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, numOfLocations);
    CGContextDrawLinearGradient(ctx, gradient, self.bounds.origin, end, 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(space);

}

- (void)animate
{
    static const NSUInteger max = 2 * FRAMES_PER_SEC;
    if (self.gradientCount++ >= max) {
        self.gradientCount = 0;
    }
    [self setTextGradientLocation:(CGFloat)self.gradientCount / (CGFloat)FRAMES_PER_SEC];
}

- (void)setTextGradientLocation:(CGFloat)x
{
    static const CGFloat width = 0.2;
    x -= width;
    locations[0] = x < 0.0 ? 0.0 : (x > 1.0 ? 1.0 : x);
    locations[1] = MIN(x + width, 1.0);
    locations[2] = MIN(locations[1] + width, 1.0);
    [self.textLayer setNeedsDisplay];
}

- (void)startTextGradientAnimation
{
    if (!self.gradientTimer) {
        [self setTextGradientLocation:0];
        self.gradientTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/FRAMES_PER_SEC target:self selector:@selector(animate) userInfo:nil repeats:YES];
    }
}

- (void)stopTextGradientAnimation
{
    if (self.gradientTimer) {
        [self.gradientTimer invalidate];
        self.gradientTimer = nil;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:touch.view];
 
    if (point.x <= self.btnBaseRightTopInView) {
        self.sliding = YES;
        if (point.x <= self.btnBaseLeftTopInView) {
            self.touchBtnXDiff = self.buttonLayer.frame.size.width;            
        } else {
            self.touchBtnXDiff = self.btnBaseRightTopInView - point.x;
        }
        [self stopTextGradientAnimation];
        self.gradientCount = 0;
        [self setTextGradientLocation:0];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.sliding) {
        return;
    }
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (point.x < self.btnBaseLeftTopInView) {
        return;
    }
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    CGPoint p = self.buttonLayer.position;
    p.x = point.x - self.leftPadding + self.touchBtnXDiff - BUTTON_MARGIN - BEZEL_WIDTH;
    if (p.x <= self.btnBaseRightTopInView) {
        p.x = self.btnBasePoint.x;
    } else if (p.x >= self.btnMaxRightTopInView) {
        p.x = self.btnMaxRightTopInView;
        self.sliding = false;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    self.buttonLayer.position = p;
    
    CGFloat opaque = (point.x - self.btnBaseRightTopInView) / self.buttonLayer.frame.size.width;
    opaque = opaque > 1.0 ? 1.0 : opaque;
    opaque = 1.0 - opaque;
    self.textLayer.opacity = opaque;
    [CATransaction commit];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.sliding = NO;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.textLayer.opacity = 1.0;
        [self startTextGradientAnimation];
    }];
    self.buttonLayer.position = self.btnBasePoint;
    [CATransaction commit];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.sliding = NO;
}

@end

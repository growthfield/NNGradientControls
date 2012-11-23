#import "NNGradientLusterLayer.h"
#import "NNGradientControls.h"

@implementation NNGradientLusterLayer

- (id)init
{
    self = [super init];
    if (self) {
        self.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context
{
    CGFloat width = self.bounds.size.width;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint p = CGPointMake(BUTTON_CORNER_RADIUS - 1, BUTTON_CORNER_RADIUS);
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 BUTTON_CORNER_RADIUS,
                 2.0 * M_PI / 2.0,
                 3.0 * M_PI / 2.0,
                 false);
    p.x = width - BUTTON_CORNER_RADIUS + 1;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 BUTTON_CORNER_RADIUS,
                 3.0 * M_PI / 2.0,
                 4.0 * M_PI / 2.0,
                 false);
    CGContextAddPath(context, path);
    CGPathRelease(path);
    CGContextSetStrokeColorWithColor(context, CGWHITE(1.0, 0.5));
    CGContextSetLineWidth(context, 3.5);
    CGContextDrawPath(context, kCGPathStroke);
}

@end

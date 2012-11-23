#import "NNGradientFramedButton.h"
#import "NNGradientControls.h"
#import <QuartzCore/QuartzCore.h>

@interface NNGradientFramedButton()

@property(nonatomic) CALayer* frameLayer;
@property(nonatomic) CALayer* baseButtonLayer;

@end

@implementation NNGradientFramedButton

- (void)prepareFace
{
    UIColor* bgColor = self.backgroundColor;

    self.layer.cornerRadius = BEZEL_CORNER_RADIUS;
    self.layer.backgroundColor = CGWHITE(0.5, 1.0);
    self.layer.masksToBounds = YES;
    self.frameLayer = [CALayer layer];
    self.frameLayer.cornerRadius = BEZEL_CORNER_RADIUS;
    self.frameLayer.backgroundColor = CGWHITE(0.1, 1.0);
    [self.layer addSublayer:self.frameLayer];

    self.baseButtonLayer = [CALayer layer];
    self.baseButtonLayer.backgroundColor = bgColor.CGColor;
    [self.frameLayer addSublayer:self.baseButtonLayer];
    [self setupWithBaseLayer:self.baseButtonLayer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect b = self.bounds;
    b.size.height -= BEZEL_WIDTH * 2 + BEZEL_ADDITIONAL_BOTTOM_SIZE;
    b.size.width -= BEZEL_WIDTH * 2;
    b.origin.x = BEZEL_WIDTH;
    b.origin.y = BEZEL_WIDTH;
    self.frameLayer.frame = b;
    
    b = self.frameLayer.bounds;
    b.size.height -= BUTTON_MARGIN * 2 - BEZEL_ADDITIONAL_BOTTOM_SIZE;
    b.size.width -= BUTTON_MARGIN * 2;
    b.origin.x = BUTTON_MARGIN;
    b.origin.y = BUTTON_MARGIN;
    self.baseButtonLayer.frame = b;
}

- (CAGradientLayer*)createHighlightGradientLayer
{
    CAGradientLayer* gl = [CAGradientLayer layer];
    gl.locations = @[@0.0, @0.15, @0.15, @1.0];
    gl.colors = @[(id)CGWHITE(0.0, 0.7), (id)CGWHITE(0.1, 0.4), (id)CGWHITE(0.1, 0.4), (id)CGWHITE(0.2, 0.0)];
    return gl;
}

- (void)setStateNormal {
    [super setStateNormal];
    self.lusterLayer.hidden = NO;
}

- (void)setStateHighlight {
    [super setStateHighlight];
    self.lusterLayer.hidden = YES;
}

@end

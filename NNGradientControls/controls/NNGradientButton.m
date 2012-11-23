#import "NNGradientButton.h"
#import "NNGradientControls.h"
#import "NNGradientLusterLayer.h"

@interface NNGradientButton()

@property(nonatomic) CALayer* baseLayer;

@end

@implementation NNGradientButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self prepareFace];
        [self.layer insertSublayer:self.titleLabel.layer atIndex:self.layer.sublayers.count];
    }
    return self;
}

- (void)prepareFace
{
    [self setupWithBaseLayer:self.layer];
}

- (void)setupWithBaseLayer:(CALayer*)baseLayer
{
    self.baseLayer = baseLayer;
    self.baseLayer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.baseLayer.masksToBounds = YES;

    self.normalGradientLayer = [self createNormalGradientLayer];
    self.normalGradientLayer.hidden = YES;
    [self.baseLayer addSublayer:self.normalGradientLayer];

    self.highlightGradientLayer = [self createHighlightGradientLayer];
    self.highlightGradientLayer.hidden = YES;
    [self.baseLayer addSublayer:self.highlightGradientLayer];

    self.lusterLayer = [NNGradientLusterLayer layer];
    [self.baseLayer addSublayer:self.lusterLayer];
    [self.lusterLayer setNeedsDisplay];
    
    [self setStateNormal];
}

- (CAGradientLayer*)createNormalGradientLayer
{
    CAGradientLayer* gl = [CAGradientLayer layer];
    gl.locations = @[@0.0, @0.5, @0.5, @1.0];
    gl.colors = @[(id)CGWHITE(1.0, 0.7), (id)CGWHITE(1.0, 0.4), (id)CGWHITE(1.0, 0.3), (id)CGWHITE(1.0, 0.0)];
    return gl;
}

- (CAGradientLayer*)createHighlightGradientLayer
{
    CAGradientLayer* gl = [CAGradientLayer layer];
    gl.locations = @[@0.0, @0.5, @0.5, @1.0];
    gl.colors = @[(id)CGWHITE(0.7, 0.7), (id)CGWHITE(0.7, 0.4), (id)CGWHITE(0.7, 0.3), (id)CGWHITE(0.7, 0.0)];
    return gl;    
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        [self setStateHighlight];
    } else {
        [self setStateNormal];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.normalGradientLayer.frame = self.baseLayer.bounds;
    self.highlightGradientLayer.frame = self.baseLayer.bounds;
    self.lusterLayer.frame = CGRectInset(self.baseLayer.bounds, 0.5, 0.35);
}

- (void)setStateNormal
{
    self.normalGradientLayer.hidden = NO;
    self.highlightGradientLayer.hidden = YES;
}

- (void)setStateHighlight
{
    self.normalGradientLayer.hidden = YES;
    self.highlightGradientLayer.hidden = NO;    
}

@end

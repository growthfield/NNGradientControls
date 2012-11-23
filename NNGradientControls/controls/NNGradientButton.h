#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface NNGradientButton : UIButton

@property(nonatomic) CAGradientLayer* normalGradientLayer;
@property(nonatomic) CAGradientLayer* highlightGradientLayer;
@property(nonatomic) CALayer* lusterLayer;

- (void)setupWithBaseLayer:(CALayer*)baseLayer;
- (CAGradientLayer*)createNormalGradientLayer;
- (CAGradientLayer*)createHighlightGradientLayer;
- (void)setStateNormal;
- (void)setStateHighlight;

@end

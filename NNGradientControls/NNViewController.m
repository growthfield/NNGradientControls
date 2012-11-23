#import "NNViewController.h"

@interface NNViewController ()

@end

@implementation NNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)fireButton:(id)sender
{
    NSLog(@"NNGradientButton clicked!");
}

- (IBAction)fireFramedButton:(id)sender
{
    NSLog(@"NNGradientFramedButton clicked!");    
}

- (IBAction)fireSlideButton:(id)sender
{
    NSLog(@"NNGradientSlideButton slided!");    
}


@end

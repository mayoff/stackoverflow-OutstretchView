#import "ViewController.h"
#import "OutstretchView.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize outstretchView = _outstretchView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.outstretchView.image = [UIImage imageNamed:@"stretch.png"];
    self.outstretchView.fixedRect = CGRectMake(80, 25, 40, 60);
    self.outstretchView.fixedCenter = CGPointMake(100, 100);
}

- (void)viewDidUnload
{
    [self setOutstretchView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)pan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:sender.view];
    [sender setTranslation:CGPointZero inView:sender.view];
    CGPoint fixedCenter = self.outstretchView.fixedCenter;
    fixedCenter.x += translation.x;
    fixedCenter.y += translation.y;
    [CATransaction begin]; {
        [CATransaction setDisableActions:YES];
        self.outstretchView.fixedCenter = fixedCenter;
        [self.outstretchView layoutIfNeeded];
    } [CATransaction commit];
}

@end

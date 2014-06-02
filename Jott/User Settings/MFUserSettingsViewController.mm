//
//  MFUserSettingsViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 5/29/14.
//
//

#import "MFUserSettingsViewController.h"
#import "MFAppDelegate.h"

@interface MFUserSettingsViewController ()

@end

@implementation MFUserSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialSetup];
}

- (void)initialSetup {
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(close)];

    self.navigationItem.leftBarButtonItem = closeButton;
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundVerticalPositionAdjustment:-5 forBarMetrics:UIBarMetricsDefault];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close {
    MFAppDelegate *appDelegate = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.root dismissPresentedViewController];
}

@end

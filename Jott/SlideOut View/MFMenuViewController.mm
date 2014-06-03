//
//  MFMenuViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 5/28/14.
//
//

#import "MFMenuViewController.h"
#import "MFViewController.h"
#import "MFAppDelegate.h"

@interface MFMenuViewController ()

@end

@implementation MFMenuViewController

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
    self.view.backgroundColor = [UIColor colorWithRed:39.0/255.0 green:39.0/255.0 blue:39.0/255.0 alpha:1.0];

    MFAppDelegate *appDelegate = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
    MFViewController *main = appDelegate.root;

    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    homeButton.frame = CGRectMake(18, 115, 30, 30);
    [homeButton setImage:[UIImage imageNamed:@"home-white-128.png"] forState:UIControlStateNormal];
    [homeButton setImage:[UIImage imageNamed:@"home-blue-128.png"] forState:UIControlStateSelected];
    [homeButton addTarget:main action:@selector(presentHomeViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.frame = CGRectMake(18, 215, 30, 30);
    [settingsButton setImage:[UIImage imageNamed:@"settings-white-128.png"] forState:UIControlStateNormal];
    [settingsButton addTarget:main action:@selector(presentSettingsViewController) forControlEvents:UIControlEventTouchUpInside];

    UIButton *userSetingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    userSetingsButton.frame = CGRectMake(18, 315, 30, 30);
    [userSetingsButton setImage:[UIImage imageNamed:@"user_male2-white-128.png"] forState:UIControlStateNormal];
    [userSetingsButton addTarget:main action:@selector(presentUserSettingsViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    infoButton.frame = CGRectMake(18, 415, 30, 30);
    [infoButton setImage:[UIImage imageNamed:@"info-white-128.png"] forState:UIControlStateNormal];
    [infoButton addTarget:main action:@selector(presentInfoViewController) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:homeButton];
    [self.view addSubview:infoButton];
    [self.view addSubview:userSetingsButton];
    [self.view addSubview:settingsButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

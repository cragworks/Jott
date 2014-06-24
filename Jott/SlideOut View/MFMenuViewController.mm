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
    if (self) { }
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
    homeButton.frame = CGRectMake(20, self.view.frame.size.height*0.26 - 15, 30, 30);
    [homeButton setImage:[UIImage imageNamed:@"home-white-128.png"] forState:UIControlStateNormal];
    [homeButton addTarget:main action:@selector(presentHomeViewController) forControlEvents:UIControlEventTouchUpInside];

    UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    faceButton.frame = CGRectMake(20, self.view.frame.size.height*0.42 - 15, 30, 30);
    [faceButton setImage:[UIImage imageNamed:@"face-recognition-white-128.png"] forState:UIControlStateNormal];
    [faceButton addTarget:main action:@selector(presentFacesListViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.frame = CGRectMake(20, self.view.frame.size.height*0.58 - 15, 30, 30);
    [settingsButton setImage:[UIImage imageNamed:@"settings-white-128.png"] forState:UIControlStateNormal];
    [settingsButton addTarget:main action:@selector(presentSettingsViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    infoButton.frame = CGRectMake(20, self.view.frame.size.height*0.74 - 15, 30, 30);
    [infoButton setImage:[UIImage imageNamed:@"info-white-128.png"] forState:UIControlStateNormal];
    [infoButton addTarget:main action:@selector(presentInfoViewController) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:homeButton];
    [self.view addSubview:infoButton];
    [self.view addSubview:faceButton];
    [self.view addSubview:settingsButton];
}

- (void)setupViewConstraints {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

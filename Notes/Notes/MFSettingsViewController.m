//
//  MFSettingsViewController.m
//  Notes
//
//  Created by Mohssen Fathi on 5/6/14.
//
//

#import "MFSettingsViewController.h"

@interface MFSettingsViewController ()

@end

@implementation MFSettingsViewController

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

    UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 200, 40)];
    keyLabel.text = @"Password:";
    
    UITextField *key = [[UITextField alloc] initWithFrame:CGRectMake(50, 150, 200, 40)];
    key.layer.borderWidth = 1.0;
    key.layer.cornerRadius = 10;
    
    [self.view addSubview:key];
    [self.view addSubview:keyLabel];
    
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

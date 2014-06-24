//
//  MFSetupViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 6/19/14.
//
//

#import "MFSetupViewController.h"
#import "MFSetFaceViewController.h"
#import "MFAppDelegate.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface MFSetupViewController () {
    UITextField *enterUsername;
    UITextField *enterPassword;
    UITextField *confirmPassword;
    MFAppDelegate *appDelegate;
}

@end

@implementation MFSetupViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialSetup];
}

- (void)initialSetup {
    self.view.backgroundColor = [UIColor whiteColor];
    appDelegate = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
    
    UILabel *enterUsernameLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 5, 200, 40)];
    enterUsernameLabel.textColor = [UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0];
    [enterUsernameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0]];
    [enterUsernameLabel setText:@"Enter Username:"];
    UILabel *enterPasswordLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 105, 200, 40)];
    enterPasswordLabel.textColor = [UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0];
    [enterPasswordLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0]];
    [enterPasswordLabel setText:@"Enter Password:"];
    UILabel *confirmPasswordLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 185, 200, 40)];
    confirmPasswordLabel.textColor = [UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0];
    [confirmPasswordLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0]];
    [confirmPasswordLabel setText:@"Confirm Password:"];
    
    enterUsername = [[UITextField alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 40)];
    [enterUsername setBackgroundColor:[UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0]];
    [enterUsername setTextAlignment:NSTextAlignmentCenter];
    [enterUsername becomeFirstResponder];
    enterUsername.delegate = self;
    enterUsername.textColor = [UIColor whiteColor];
    enterUsername.tintColor = [UIColor whiteColor];
    enterUsername.autocapitalizationType = UITextAutocapitalizationTypeNone;
    enterUsername.autocorrectionType = UITextAutocorrectionTypeNo;
    if(![[appDelegate.passwordItem objectForKey:(__bridge id)kSecValueData] isEqualToString:@""]) enterUsername.text = [appDelegate.passwordItem objectForKey:(__bridge id)kSecAttrAccount];
    
    
    enterPassword = [[UITextField alloc] initWithFrame:CGRectMake(0, 140, self.view.frame.size.width, 40)];
    [enterPassword setBackgroundColor:[UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0]];
    [enterPassword setTextAlignment:NSTextAlignmentCenter];
    enterPassword.delegate = self;
    enterPassword.secureTextEntry = YES;
    enterPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    enterPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    enterPassword.textColor = [UIColor whiteColor];
    enterPassword.tintColor = [UIColor whiteColor];
    enterPassword.clearsOnBeginEditing = YES;
    if(![[appDelegate.passwordItem objectForKey:(__bridge id)kSecAttrAccount] isEqualToString:@""]) enterPassword.text = [appDelegate.passwordItem objectForKey:(__bridge id)kSecValueData];
    
    confirmPassword = [[UITextField alloc]initWithFrame:CGRectMake(0, 220, self.view.frame.size.width, 40)];
    [confirmPassword setBackgroundColor:[UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0]];
    [confirmPassword setTextAlignment:NSTextAlignmentCenter];
    confirmPassword.secureTextEntry = YES;
    confirmPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    confirmPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    confirmPassword.clearsOnBeginEditing = YES;
    confirmPassword.textColor = [UIColor whiteColor];
    confirmPassword.tintColor = [UIColor whiteColor];
    if(![[appDelegate.passwordItem objectForKey:(__bridge id)kSecValueData] isEqualToString:@""]) confirmPassword.text = [appDelegate.passwordItem objectForKey:(__bridge id)kSecValueData];
    
    
    if (!IS_IPHONE_5) {
        enterUsernameLabel.frame = CGRectMake(20, 0, 200, 25);
        enterPasswordLabel.frame = CGRectMake(20, 67, 200, 30);
        confirmPasswordLabel.frame = CGRectMake(20, 132, 200, 30);
        
        enterUsername.frame = CGRectMake(0, 20, self.view.frame.size.width, 40);
        enterPassword.frame = CGRectMake(0, 92, self.view.frame.size.width, 40);
        confirmPassword.frame = CGRectMake(0, 157, self.view.frame.size.width, 40);
    }
    
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    self.navigationItem.rightBarButtonItem = save;
    [self.view addSubview:enterUsername];
    [self.view addSubview:enterPassword];
    [self.view addSubview:confirmPassword];
    [self.view addSubview:enterUsernameLabel];
    [self.view addSubview:enterPasswordLabel];
    [self.view addSubview:confirmPasswordLabel];
}

- (void)save {
    /*   If problems saving, use [keychainWrapper resetKeychainItem] to erase all entries in keychain   */
    
    if ([[enterUsername text] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Username"
                                                        message:@"Please enter a valid username."
                                                       delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (![[enterPassword text] isEqualToString:[confirmPassword text]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Mismatch"
                                                        message:@"Passwords do not match."
                                                       delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if ([[enterPassword text] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Password"
                                                        message:@"Please enter a valid password."
                                                       delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    [appDelegate.passwordItem setObject:enterPassword.text forKey:(__bridge id)kSecValueData];
    [appDelegate.passwordItem setObject:enterUsername.text forKey:(__bridge id)kSecAttrAccount];
    [appDelegate refreshPassword];
    
    MFSetFaceViewController *setFaceViewController = [[MFSetFaceViewController alloc] init];
    [self.navigationController pushViewController:setFaceViewController animated:YES];
    
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

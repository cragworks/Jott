//
//  MFSetPasswordViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 5/24/14.
//
//

#import "MFAppDelegate.h"
#import "MFSetPasswordViewController.h"
#import "MFKeychainWrapper.h"
#import "MFViewController.h"
#import "MFAppDelegate.h"

@interface MFSetPasswordViewController ()

@end

@implementation MFSetPasswordViewController

@synthesize textValue, editedFieldKey, textControl, keychainWrapper, confirmTextControl, setPassword;

- (void)viewDidLoad {
   
    self.view.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:255.0/255.0 alpha:1.0];
    
    (setPassword) ? [self passwordSetup] : [self userSetup];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.leftBarButtonItem = cancel;
    self.navigationItem.rightBarButtonItem = save;
    
}

- (void)passwordSetup {
    UILabel *enterPasswordLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 115, 200, 40)];
    [enterPasswordLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
    [enterPasswordLabel setText:@"Enter New Password:"];
    UILabel *confirmPasswordLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 215, 200, 40)];
    [confirmPasswordLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
    [confirmPasswordLabel setText:@"Confirm Password:"];
    
    textControl = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 125, 150, 250, 40)];
    [textControl setBackgroundColor:[UIColor whiteColor]];
    [textControl setBorderStyle:UITextBorderStyleLine];
    [textControl setTextAlignment:NSTextAlignmentCenter];
    textControl.placeholder = nil;
    textControl.delegate = self;
    textControl.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textControl.autocorrectionType = UITextAutocorrectionTypeNo;
    textControl.secureTextEntry = NO;
    
    confirmTextControl = [[UITextField alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 125, 250, 250, 40)];
    [confirmTextControl setBackgroundColor:[UIColor whiteColor]];
    [confirmTextControl setBorderStyle:UITextBorderStyleLine];
    [confirmTextControl setTextAlignment:NSTextAlignmentCenter];
    confirmTextControl.autocapitalizationType = UITextAutocapitalizationTypeNone;
    confirmTextControl.autocorrectionType = UITextAutocorrectionTypeNo;
    confirmTextControl.text = @"";
    
    [self.view addSubview:textControl];
    [self.view addSubview:confirmTextControl];
    [self.view addSubview:enterPasswordLabel];
    [self.view addSubview:confirmPasswordLabel];
}

- (void)userSetup {
    UILabel *enterUserLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 115, 200, 40)];
    [enterUserLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
    [enterUserLabel setText:@"Enter Username:"];
    
    textControl = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 125, 150, 250, 40)];
    [textControl setBackgroundColor:[UIColor whiteColor]];
    [textControl setBorderStyle:UITextBorderStyleLine];
    [textControl setTextAlignment:NSTextAlignmentCenter];
    textControl.placeholder = nil;
    textControl.delegate = self;
    textControl.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textControl.autocorrectionType = UITextAutocorrectionTypeNo;
    textControl.secureTextEntry = NO;

    [self.view addSubview:textControl];
    [self.view addSubview:enterUserLabel];
}

- (void)awakeFromNib
{
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [textControl setFont:[UIFont boldSystemFontOfSize:16]];
}

- (void)cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (buttonIndex == 1) {
        [textControl setText:@""];
        [confirmTextControl setText:@""];
        [textControl becomeFirstResponder];
    }
}

- (void)save
{
    if (setPassword) {
        if (![[textControl text] isEqualToString:[confirmTextControl text]]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Mismatch" message:@"Passwords do not match. Would you like to try again?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
            [alert show];
            return;
        }
        if (![[textControl text] isEqualToString:@""]) {
            MFViewController *viewController = [[MFViewController alloc]init];
            [viewController changeEncryptionFromOldPassword:[keychainWrapper objectForKey:(__bridge id)(kSecValueData)] toNewPassword:[textControl text]];
            [keychainWrapper setObject:[textControl text] forKey:editedFieldKey];
        }
    }
    else {
        [keychainWrapper setObject:[textControl text] forKey:editedFieldKey];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [textControl becomeFirstResponder];
    [textControl setText:textValue];
}

@end

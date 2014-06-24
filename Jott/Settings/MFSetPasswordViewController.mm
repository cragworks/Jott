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
#import "MFNotesModel.h"

@interface MFSetPasswordViewController ()

@end

@implementation MFSetPasswordViewController

@synthesize textValue, editedFieldKey, textControl, keychainWrapper, confirmTextControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialSetup];
}

- (void)initialSetup {
    self.view.backgroundColor = [UIColor whiteColor];
    
    textControl = [[UITextField alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height*0.12, self.view.frame.size.width, 50)];
    [textControl setBackgroundColor:[UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0]];
    [textControl setTextAlignment:NSTextAlignmentCenter];
    textControl.placeholder = nil;
    textControl.delegate = self;
    textControl.secureTextEntry = YES;
    textControl.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textControl.autocorrectionType = UITextAutocorrectionTypeNo;
    textControl.clearsOnBeginEditing = YES;
    textControl.textColor = [UIColor whiteColor];
    textControl.tintColor = [UIColor whiteColor];
    [textControl setFont:[UIFont fontWithName:@"HelveticaNeue" size:20.0]];
    
    confirmTextControl = [[UITextField alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height*0.3, self.view.frame.size.width, 50)];
    [confirmTextControl setBackgroundColor:[UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0]];
    [confirmTextControl setTextAlignment:NSTextAlignmentCenter];
    confirmTextControl.secureTextEntry = YES;
    confirmTextControl.autocapitalizationType = UITextAutocapitalizationTypeNone;
    confirmTextControl.autocorrectionType = UITextAutocorrectionTypeNo;
    confirmTextControl.clearsOnBeginEditing = YES;
    confirmTextControl.textColor = [UIColor whiteColor];
    confirmTextControl.tintColor = [UIColor whiteColor];
    [confirmTextControl setFont:[UIFont fontWithName:@"HelveticaNeue" size:20.0]];
    
    UILabel *enterPasswordLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, textControl.frame.origin.y - 35, 200, 40)];
    [enterPasswordLabel setText:@"Enter New Password:"];
    enterPasswordLabel.textColor = [UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0];
    [enterPasswordLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
    
    UILabel *confirmPasswordLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, confirmTextControl.frame.origin.y - 35, 200, 40)];
    [confirmPasswordLabel setText:@"Confirm New Password:"];
    confirmPasswordLabel.textColor = [UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0];
    [confirmPasswordLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
   
    self.navigationItem.leftBarButtonItem = cancel;
    self.navigationItem.rightBarButtonItem = save;
    [self.view addSubview:textControl];
    [self.view addSubview:confirmTextControl];
    [self.view addSubview:enterPasswordLabel];
    [self.view addSubview:confirmPasswordLabel];
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
    
    /*   If problems saving, use [keychainWrapper resetKeychainItem] to erase all entries in keychain   */
    
    if (![[textControl text] isEqualToString:[confirmTextControl text]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Mismatch" message:@"Passwords do not match. Would you like to try again?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
        [alert show];
        return;
    }
    if (![[textControl text] isEqualToString:@""]) {
        MFViewController *viewController = [[MFViewController alloc]init];
        [viewController changeEncryptionFromOldPassword:[keychainWrapper objectForKey:editedFieldKey] toNewPassword:[textControl text]];
        [keychainWrapper setObject:[textControl text] forKey:editedFieldKey];
        
        MFAppDelegate *appDelegate = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate refreshPassword];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [textControl becomeFirstResponder];
    [textControl setText:textValue];
}

@end

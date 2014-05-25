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

@interface MFSetPasswordViewController ()

@end

@implementation MFSetPasswordViewController

@synthesize textValue, editedFieldKey, textControl, keychainWrapper;

- (void)viewDidLoad {
   
    self.view.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:255.0/255.0 alpha:1.0];
    
    textControl = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 125, 150, 250, 40)];
    [textControl setBackgroundColor:[UIColor whiteColor]];
    [textControl setBorderStyle:UITextBorderStyleLine];
    [textControl setTextAlignment:NSTextAlignmentCenter];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    
    self.navigationItem.leftBarButtonItem = cancel;
    self.navigationItem.rightBarButtonItem = save;
    [self.view addSubview:textControl];
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

- (void)save
{
    /*
     Decrypt and Re-Encrypt every note with new password
     -create method in mainViewController with 2 arguments, old password, new password. Run through cellForRowAtIndexPath (for each note)
     */
    
    [keychainWrapper setObject:[textControl text] forKey:editedFieldKey];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [textControl becomeFirstResponder];
    [textControl setText:textValue];
}

@end

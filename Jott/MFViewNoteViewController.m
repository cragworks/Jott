//
//  MFViewNoteViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 5/21/14.
//
//

#import "MFViewNoteViewController.h"
#import "MFViewController.h"
#import "MFNotesModel.h"
#import "MFNote.h"
#import "MFViewController.h"
#import "MFAppDelegate.h"
#import "NSString+AESCrypt.h"

@interface MFViewNoteViewController () {
    BOOL isBeingEdited;
    BOOL isEncrypted;
    UIBarButtonItem *back;
    UIBarButtonItem *edit;
    UIButton *cryptButton;
    MFViewController *presentingViewController;
}
@end

@implementation MFViewNoteViewController

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
    
    //
    //  Remove password storage later
    //
    
    MFAppDelegate *appDelegate = (MFAppDelegate *)[[UIApplication sharedApplication] delegate];
    _password = appDelegate.password;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    presentingViewController = (MFViewController *)self.presentingViewController;
    isEncrypted = presentingViewController.currentNote.isEncrypted;
    
    back = [[UIBarButtonItem alloc]initWithTitle: @"Done" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    edit = [[UIBarButtonItem alloc]initWithTitle: @"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(edit)];
    UIView *cryptView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    cryptButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cryptButton.frame = CGRectMake(0, 0, 100, 50);
    [cryptButton setTitle:@"Decrypt" forState:UIControlStateNormal];
    [cryptButton addTarget:self action:@selector(decryptButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [cryptView addSubview:cryptButton];
    
    _titleField = [[UITextField alloc] initWithFrame:CGRectMake(10, 70, self.view.frame.size.width - 20, 50)];
    _titleField.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:250.0/255.0 blue:240.0/255.0 alpha:1.0];
    _titleField.userInteractionEnabled = NO;
    _titleField.text = presentingViewController.currentNote.title;

    [_titleField becomeFirstResponder];
    
    _noteField = [[UITextField alloc] initWithFrame:CGRectMake(10, 125, self.view.frame.size.width - 20, 400)];
    _noteField.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:250.0/255.0 blue:240.0/255.0 alpha:1.0];
    _noteField.userInteractionEnabled = NO;
    _noteField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    _noteField.text = presentingViewController.currentNote.text;
    
    self.navigationItem.leftBarButtonItem = back;
    self.navigationItem.rightBarButtonItem = edit;
    self.navigationItem.titleView = cryptView;
    [self.view addSubview:_titleField];
    [self.view addSubview:_noteField];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([[alertView textFieldAtIndex:0].text isEqualToString:_password]) {
        [self changeTextEncryption];
    }
}

- (void)decryptButtonTapped {
    if (!isEncrypted) {
        [self changeTextEncryption];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter Password"
                                                            message:@"Enter the key to decrypt text:"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Enter", nil];
        alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [alertView show];
    }
}

- (void)changeTextEncryption {
    
    if (!isBeingEdited) {
        if (isEncrypted) {
            [cryptButton setTitle:@"Encrypt" forState:UIControlStateNormal];
            
            [self decryptText];
            
            isEncrypted = NO;
            presentingViewController.currentNote.isEncrypted = NO;
        }
        else {
            [cryptButton setTitle:@"Decrypt" forState:UIControlStateNormal];
            
            [self encryptText];
            
            isEncrypted = YES;
            presentingViewController.currentNote.isEncrypted = YES;
        }
    }
}

- (void)decryptText {
    presentingViewController.currentNote.title = [presentingViewController.currentNote.title AES256DecryptWithKey:_password];
    presentingViewController.currentNote.text = [presentingViewController.currentNote.text AES256DecryptWithKey:_password];
    _titleField.text = presentingViewController.currentNote.title;
    _noteField.text = presentingViewController.currentNote.text;
    
}

- (void)encryptText {
    presentingViewController.currentNote.title = [presentingViewController.currentNote.title AES256EncryptWithKey:_password];
    presentingViewController.currentNote.text = [presentingViewController.currentNote.text AES256EncryptWithKey:_password];
    _titleField.text = presentingViewController.currentNote.title;
    _noteField.text = presentingViewController.currentNote.text;
}

- (void)cancel {
    isEncrypted = YES;
    [self encryptText];
    presentingViewController.currentNote.isEncrypted = YES;
    [(MFViewController *)self.presentingViewController dismissPresentedViewController];
}

- (void)edit {
    if (!isEncrypted) {
        if (isBeingEdited) {
            edit.title = @"Edit";
            back.title = @"Done";
            _titleField.userInteractionEnabled = NO;
            _noteField.userInteractionEnabled = NO;
            isBeingEdited = NO;
            
            presentingViewController.currentNote.title = _titleField.text;
            presentingViewController.currentNote.text = _noteField.text;
        }
        else {
            edit.title = @"Save";
            back.title = @"Cancel";
            _titleField.userInteractionEnabled = YES;
            _noteField.userInteractionEnabled = YES;
            [_titleField becomeFirstResponder];
            isBeingEdited = YES;
        }
    }
}

- (void)save {
    presentingViewController = (MFViewController *)self.presentingViewController;
    MFNote *mfnote = [NSEntityDescription insertNewObjectForEntityForName:@"MFNote" inManagedObjectContext:presentingViewController.managedObjectContext];
    mfnote.title = _titleField.text;
    mfnote.text = _noteField.text;
    NSError *error = nil;
    [presentingViewController.managedObjectContext save:&error];
    
    [[MFNotesModel sharedModel] addNote:mfnote];
    [presentingViewController dismissPresentedViewController];
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

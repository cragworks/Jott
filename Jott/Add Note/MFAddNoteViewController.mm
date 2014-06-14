//
//  MFAddNoteViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 5/18/14.
//
//

#import "MFAddNoteViewController.h"
#import "MFViewController.h"
#import "MFNotesModel.h"
#import "MFNote.h"
#import "NSString+AESCrypt.h"
#import "NSData+AESCrypt.h"
#import "MFAppDelegate.h"
#import "UIImage+ImageEffects.h"

@interface MFAddNoteViewController ()

@end

@implementation MFAddNoteViewController {
    UITextField *titleView;
    UITextView *noteView;
    NSString *password;
    MFViewController *presentingViewController;
}

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHeight:) name:UIKeyboardDidShowNotification object:nil];

    UIImage *background = [UIImage imageNamed:@"paper2.png"];
    background = [UIImage imageWithCGImage:[background CGImage]
                                     scale:(background.scale * 2.0)
                               orientation:(background.imageOrientation)];
    self.view.backgroundColor = [UIColor colorWithPatternImage:background];
    
    UIImage *lineImage = [UIImage imageNamed:@"line.png"];
    UIImageView *line = [[UIImageView alloc] initWithImage:lineImage];
    line.frame = CGRectMake(self.view.frame.size.width/2 - 135, 50, 270, 1);
    
    MFAppDelegate *appDelegate = (MFAppDelegate *)[[UIApplication sharedApplication] delegate];
    password = appDelegate.password;
    presentingViewController = appDelegate.root;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:appDelegate.root.background];
    
    //UIBarButtonItem *cancel = [[UIBarButtonItem alloc]initWithTitle: @"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNote)];
    UIBarButtonItem *save = [[UIBarButtonItem alloc]initWithTitle: @"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveNote)];
    
    titleView = [[UITextField alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width - 20, 35)];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.placeholder = @"Title";
    titleView.delegate = self;
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:26.0];
    [titleView becomeFirstResponder];
    
    noteView = [[UITextView alloc] initWithFrame:CGRectMake(10, 55, self.view.frame.size.width - 20, 363)];
    noteView.backgroundColor = [UIColor clearColor];
    noteView.delegate = self;
    noteView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    
    self.navigationItem.rightBarButtonItem = save;
    [self.view addSubview:titleView];
    [self.view addSubview:noteView];
    [self.view addSubview:line];
}

- (void)keyboardHeight:(NSNotification*)notification
{
    int h;
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    if (keyboardFrameBeginRect.size.height > 225.0) {
        h = 223;
    }
    else if (keyboardFrameBeginRect.size.height < 225.0) {
        h = 193;
    };
    noteView.frame = CGRectMake(10, 55, self.view.frame.size.width - 20, h);
    NSLog(@"%f", keyboardFrameBeginRect.size.height);
}

- (void)keyboardWillHide:(id)sender {
    noteView.frame = CGRectMake(10, 70, self.view.frame.size.width - 20, 350);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [noteView becomeFirstResponder];
    return NO;
}

- (void) saveNote {
    MFNote *mfnote = [NSEntityDescription insertNewObjectForEntityForName:@"MFNote" inManagedObjectContext:presentingViewController.managedObjectContext];
    mfnote.title = titleView.text;
    mfnote.text = [self encryptText:noteView.text];
    mfnote.isEncrypted = YES;

    NSError *error = nil;
    [presentingViewController.managedObjectContext save:&error];
    
    [[MFNotesModel sharedModel] addNote:mfnote];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (NSString *)encryptText:(NSString *)text {
    MFAppDelegate *ad = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
    MFKeychainWrapper *wrapper = ad.wrapper;
    NSString *encryptedText = [text AES256EncryptWithKey:[wrapper objectForKey:(__bridge id)(kSecValueData)]];
    
    return encryptedText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end

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

@interface MFAddNoteViewController ()

@end

@implementation MFAddNoteViewController {
    UITextField *titleField;
    UITextField *noteField;
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
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]initWithTitle: @"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNote)];
    UIBarButtonItem *save = [[UIBarButtonItem alloc]initWithTitle: @"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveNote)];
    
    titleField = [[UITextField alloc] initWithFrame:CGRectMake(10, 70, self.view.frame.size.width - 20, 50)];
    titleField.delegate = self;
    titleField.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:250.0/255.0 blue:240.0/255.0 alpha:1.0];
    titleField.borderStyle = UITextBorderStyleBezel;
    [titleField becomeFirstResponder];
    
    noteField = [[UITextField alloc] initWithFrame:CGRectMake(10, 125, self.view.frame.size.width - 20, 400)];
    noteField.delegate = self;
    noteField.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:250.0/255.0 blue:240.0/255.0 alpha:1.0];
    noteField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    noteField.borderStyle = UITextBorderStyleBezel;
    
    
    self.navigationItem.leftBarButtonItem = cancel;
    self.navigationItem.rightBarButtonItem = save;
    [self.view addSubview:titleField];
    [self.view addSubview:noteField];
}

- (void) cancelNote {
    [(MFViewController *)self.presentingViewController dismissPresentedViewController];
}

- (void) saveNote {
    MFViewController *presentingViewController = (MFViewController *)self.presentingViewController;
    MFNote *mfnote = [NSEntityDescription insertNewObjectForEntityForName:@"MFNote" inManagedObjectContext:presentingViewController.managedObjectContext];
    mfnote.title = titleField.text;
    mfnote.text = noteField.text;
    mfnote.title = [self encryptText:titleField.text];
    mfnote.text = [self encryptText:noteField.text];
    mfnote.isEncrypted = YES;

    NSError *error = nil;
    [presentingViewController.managedObjectContext save:&error];
    
    [[MFNotesModel sharedModel] addNote:mfnote];
    [presentingViewController dismissPresentedViewController];
}

- (NSString *)encryptText:(NSString *)text {
    NSString *encryptedText = [text AES256EncryptWithKey:@"Mohssen"];
    
    return encryptedText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}


@end

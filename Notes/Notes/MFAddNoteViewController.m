//
//  MFAddNoteViewController.m
//  Notes
//
//  Created by Mohssen Fathi on 5/13/14.
//
//

#import "MFAddNoteViewController.h"
#import "MFListItem.h"

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

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialSetup];
}

- (void)initialSetup {
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelButton.frame = CGRectMake(10, 25, 60, 40);
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelNote) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    saveButton.frame = CGRectMake(self.view.frame.size.width - 55, 25, 40, 40);
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveNote) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    [self.view addSubview:cancelButton];
    [self.view addSubview:saveButton];
    [self.view addSubview:titleField];
    [self.view addSubview:noteField];
}

- (void) cancelNote {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) saveNote {
    MFListItem *listItem = [[MFListItem alloc] init];
    listItem.title = titleField.text;
    listItem.text = noteField.text;
    
    [self dismissViewControllerAnimated:YES completion:nil];
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

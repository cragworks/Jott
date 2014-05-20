//
//  MFAddNoteViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 5/18/14.
//
//

#import "MFAddNoteViewController.h"
#import "MFAddNoteView.h"
#import "MFViewController.h"
#import "MFNotesModel.h"
#import "MFNote.h"

@interface MFAddNoteViewController ()

@end

@implementation MFAddNoteViewController {
    UITextField *titleField;
    UITextField *noteField;
    MFAddNoteView *view;
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
    view = [[MFAddNoteView alloc] initWithFrame:self.view.bounds];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]initWithTitle: @"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNote)];
    UIBarButtonItem *save = [[UIBarButtonItem alloc]initWithTitle: @"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveNote)];

    
    [view.cancelButton addTarget:self action:@selector(cancelNote) forControlEvents:UIControlEventTouchUpInside];
    [view.saveButton addTarget:self action:@selector(saveNote) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:view];
    self.navigationItem.leftBarButtonItem = cancel;
    self.navigationItem.rightBarButtonItem = save;
    
}

- (void) cancelNote {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) saveNote {
    MFNote *note = [[MFNote alloc] init];
    note.title = titleField.text;
    note.text = noteField.text;
    
    [[MFNotesModel sharedModel] addNote:note];
    [[MFViewController sharedController] reloadTableView];
    
//    [self dismissViewControllerAnimated:YES completion:^{
//        [[MFViewController sharedController] reloadTableView];
//    }];
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

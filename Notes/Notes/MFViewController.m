//
//  MFViewController.m
//  Notes
//
//  Created by Mohssen Fathi on 5/13/14.
//
//

#import "MFViewController.h"
#import "MFNotesList.h"
#import "MFAddNoteViewController.h"

@interface MFViewController ()

@end

@implementation MFViewController {
    MFNotesList *list;
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
    list = [[MFNotesList alloc] init];
    CGRect listFrame = CGRectMake(10, self.view.frame.size.height*0.1, self.view.frame.size.width - 20, self.view.frame.size.height*0.8);
    list.view.frame = listFrame;
    
    [self.view addSubview:list.view];
    [self addNewButton];
}

- (void)addNote {
    MFAddNoteViewController *anvc = [[MFAddNoteViewController alloc] init];
    [self presentViewController:anvc animated:YES completion:nil];
}

- (void)addNewButton {
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(self.view.frame.size.width - 45, 30, 35, 35);
    [addButton setImage:[UIImage imageNamed:@"plus-50.png"] forState:UIControlStateNormal];
    
    [addButton addTarget:self action:@selector(addNote) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:addButton];
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

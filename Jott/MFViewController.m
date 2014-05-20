//
//  MFViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 5/16/14.
//
//

#import "MFViewController.h"
#import "MFNotesModel.h"
#import "MFMainView.h"
#import "MFAddNoteViewController.h"

@interface MFViewController ()

@end

@implementation MFViewController {
    MFAddNoteViewController *anvc;
}

static MFViewController *sharedViewController = nil;
+ (MFViewController *)sharedController {
    if (sharedViewController == nil) {
        sharedViewController = [[super allocWithZone:NULL] init];
    }
    return sharedViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialSetup];
}

- (void)initialSetup {
    _mainView = [[MFMainView alloc] initWithFrame:self.view.bounds];
    _mainView.tableView.delegate = self;
    _mainView.tableView.dataSource = [MFNotesModel sharedModel];
    
	[self.view addSubview:_mainView];
    
    [_mainView.addButton addTarget:self action:@selector(addNote) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addNote {
//    NSArray *colors = [[NSArray alloc] initWithObjects:[UIColor redColor], [UIColor grayColor], [UIColor blueColor], nil];
//    _mainView.tableView.backgroundColor = [colors objectAtIndex:arc4random()%3];
    
    anvc = [[MFAddNoteViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:anvc];
    
    [self presentViewController:navController animated:YES completion:nil];
    NSLog(@"1: %@",self.presentedViewController);
}

- (void)reloadTableView {
    self.presentedViewController.view.backgroundColor = [UIColor redColor];
    NSLog(@"2: %@",self.presentedViewController);
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    //[_mainView reloadTableView];
    //[_mainView.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

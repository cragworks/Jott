//
//  MFViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 5/16/14.
//
//

#import "MFViewController.h"
#import "MFNotesModel.h"
#import "MFAddNoteViewController.h"

@interface MFViewController ()

@end

@implementation MFViewController {
    MFAddNoteViewController *anvc;
}
//
//static MFViewController *sharedViewController = nil;
//+ (MFViewController *)sharedController {
//    if (sharedViewController == nil) {
//        sharedViewController = [[super allocWithZone:NULL] init];
//    }
//    return sharedViewController;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialSetup];
}

- (void)initialSetup {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height*0.1, self.view.frame.size.width - 20, self.view.frame.size.height*0.8) style:UITableViewStylePlain];
    _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _addButton.frame = CGRectMake(self.view.frame.size.width - 45, 30, 30, 30);
    [_addButton setImage:[UIImage imageNamed:@"plus-50.png"] forState:UIControlStateNormal];
    
    [self.view addSubview:_addButton];
    [self.view addSubview:_tableView];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_addButton addTarget:self action:@selector(addNote) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addNote {
    
    anvc = [[MFAddNoteViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:anvc];
    
    [self presentViewController:navController animated:YES completion:nil];
   // NSLog(@"1: %@",self.presentedViewController);
}

- (void)cancelNote {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveNote {

    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    //[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"%lu\n",[_notesList count]);
    return [[MFNotesModel sharedModel].notesList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [[[MFNotesModel sharedModel].notesList objectAtIndex:(NSUInteger)indexPath] description];
    
    return cell;
}


@end

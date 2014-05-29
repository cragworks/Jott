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
#import "MFAppDelegate.h"
#import "MFViewNoteViewController.h"
#import "MFSettingsViewController.h"
#import "NSString+AESCrypt.h"
#import "NSData+AESCrypt.h"
#import "SWRevealViewController.h"
#import "MFInfoViewController.h"

@interface MFViewController ()

@end

@implementation UINavigationBar (customNav)
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(self.frame.size.width,60);
    return newSize;
}
@end

@implementation MFViewController {
    MFAddNoteViewController *anvc;
    MFAppDelegate *delegate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialSetup];
}

- (void)initialSetup {
    self.view.backgroundColor = [UIColor whiteColor];
    
    delegate = (MFAppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = delegate.managedObjectContext;
    
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    self.revealViewController.delegate = self;
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu.png"]style:UIBarButtonItemStyleBordered target:revealController action:@selector(revealToggle:)];
    _addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus-32.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addNote)];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MFNote" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *notes = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [MFNotesModel sharedModel].notesList = [notes mutableCopy];;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    _tableView.rowHeight = 75.0;

    [self.navigationItem.leftBarButtonItem setBackgroundVerticalPositionAdjustment:50 forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    self.navigationItem.rightBarButtonItem = _addButton;
    [self.view addSubview:_tableView];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
}

- (void)changeEncryptionFromOldPassword:(NSString *)oldPassword toNewPassword:(NSString *)newPassword; {
    for (MFNote *note in [[MFNotesModel sharedModel] notesList]) {
        note.text = [note.text AES256DecryptWithKey:oldPassword];
        note.text = [note.text AES256EncryptWithKey:newPassword];
        note.title = [note.title AES256DecryptWithKey:oldPassword];
        note.title = [note.title AES256EncryptWithKey:newPassword];
    }
    [self.tableView reloadData];
}

- (void)addNote {
    anvc = [[MFAddNoteViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:anvc];
    [self presentViewController:navController animated:YES completion:nil];
}


#pragma mark - Present View Controllers

- (void)presentSettingsViewController {
    MFSettingsViewController *svc = [delegate settingsViewController];
    [svc.tableView setScrollEnabled:NO];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:svc];
    navController.navigationBar.tintColor = [UIColor whiteColor];
    navController.navigationBar.barTintColor = [UIColor colorWithRed:5.0/255.0 green:155.0/255.0 blue:250.0/255.0 alpha:1.0];
    navController.navigationBar.translucent = NO;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)presentUserSettingsViewController {
    MFSettingsViewController *svc = [delegate settingsViewController];
    [svc.tableView setScrollEnabled:NO];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:svc];
    navController.navigationBar.tintColor = [UIColor whiteColor];
    navController.navigationBar.barTintColor = [UIColor colorWithRed:5.0/255.0 green:155.0/255.0 blue:250.0/255.0 alpha:1.0];
    navController.navigationBar.translucent = NO;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)presentInfoViewController {
    MFInfoViewController *ivc = [[MFInfoViewController alloc]init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:ivc];
    navController.navigationBar.tintColor = [UIColor whiteColor];
    navController.navigationBar.barTintColor = [UIColor colorWithRed:5.0/255.0 green:155.0/255.0 blue:250.0/255.0 alpha:1.0];
    navController.navigationBar.translucent = NO;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)presentViewNoteViewController {
    MFViewNoteViewController *viewNoteController = [[MFViewNoteViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewNoteController];
    navController.navigationBar.tintColor = [UIColor whiteColor];
    navController.navigationBar.barTintColor = [UIColor colorWithRed:5.0/255.0 green:155.0/255.0 blue:250.0/255.0 alpha:1.0];
    navController.navigationBar.translucent = NO;
    [navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)dismissPresentedViewController {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[MFNotesModel sharedModel].notesList count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _currentNote = [[MFNotesModel sharedModel].notesList objectAtIndex:indexPath.row];
    [self presentViewNoteViewController];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_managedObjectContext deleteObject:[[MFNotesModel sharedModel].notesList objectAtIndex:indexPath.row]];
        NSError *error = nil;
        if (![_managedObjectContext save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }

        [[MFNotesModel sharedModel].notesList removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [[[MFNotesModel sharedModel].notesList objectAtIndex:[indexPath row]] title];
    cell.detailTextLabel.text = [[[MFNotesModel sharedModel].notesList objectAtIndex:[indexPath row]] text];
    
    return cell;
}


#pragma mark - SWRevealViewController Delegate Methods

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position {
    if(position == FrontViewPositionLeft) {
        self.view.userInteractionEnabled = YES;
    } else {
        self.view.userInteractionEnabled = NO;
    }
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position {
    if(position == FrontViewPositionLeft) {
        self.view.userInteractionEnabled = YES;
    } else {
        self.view.userInteractionEnabled = NO;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

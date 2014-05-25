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

@interface MFViewController ()

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
    delegate = (MFAppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = delegate.managedObjectContext;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MFNote" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *notes = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [MFNotesModel sharedModel].notesList = [notes mutableCopy];;
    //[[MFNotesModel sharedModel].notesList addObjectsFromArray:[MFNotesModel sharedModel].notesList];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height*0.15, self.view.frame.size.width - 20, self.view.frame.size.height*0.7) style:UITableViewStylePlain];
    _tableView.rowHeight = 75.0;
    
    _settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _settingsButton.frame = CGRectMake(20, 45, 25, 25);
    [_settingsButton setImage:[UIImage imageNamed:@"settings-50.png"] forState:UIControlStateNormal];
    
    _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _addButton.frame = CGRectMake(self.view.frame.size.width - 45, 40, 30, 30);
    [_addButton setImage:[UIImage imageNamed:@"plus-50.png"] forState:UIControlStateNormal];
    
    [self.view addSubview:_settingsButton];
    [self.view addSubview:_addButton];
    [self.view addSubview:_tableView];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_settingsButton addTarget:self action:@selector(presentSettingsViewController) forControlEvents:UIControlEventTouchUpInside];
    [_addButton addTarget:self action:@selector(addNote) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addNote {
    
    anvc = [[MFAddNoteViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:anvc];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)presentSettingsViewController {
    MFSettingsViewController *svc = [delegate settingsViewController];
    [svc.tableView setScrollEnabled:NO];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:svc];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)presentViewNoteViewController {
    MFViewNoteViewController *viewNoteController = [[MFViewNoteViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewNoteController];
    [navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)dismissPresentedViewController {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
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


@end

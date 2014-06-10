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
#import "MFUserSettingsViewController.h"
#import "UIImage+ImageEffects.h"
#import "JCRBlurView.h"

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
    UIImageView *cellBlur;
    CGFloat scrollHeight;
    SWRevealViewController *revealController;
    UIImage *navBarBackground;
    UIImage *listBackground;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialSetup];
}

- (void)initialSetup {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"firstTime"] != NO) {
        [defaults setBool:NO forKey:@"firstTime"];
        [defaults setInteger:100 forKey:@"sensitivity"];
        [self presentFirstTimeView];
    }
    
    //listBackground = [UIImage imageNamed:@"bg6.jpg"];
    listBackground = [[UIImage imageNamed:@"bg6.jpg"] applyLightEffect];
//    listBackground = [UIImage imageWithCGImage:[listBackground CGImage]
//                        scale:(listBackground.scale * 1.73)
//                  orientation:(listBackground.imageOrientation)];
    
    navBarBackground = [UIImage imageNamed:@"2-.png"];
    navBarBackground = [UIImage imageWithCGImage:[navBarBackground CGImage]
                                         scale:(navBarBackground.scale * 2.5)
                                   orientation:(navBarBackground.imageOrientation)];

    [self.navigationController.navigationBar setFrame:CGRectMake(0, 0, 320, 100)];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundVerticalPositionAdjustment:-4 forBarMetrics:UIBarMetricsDefault];
    
    delegate = (MFAppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = delegate.managedObjectContext;
    
    revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    self.revealViewController.delegate = self;
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu.png"]style:UIBarButtonItemStyleBordered target:revealController action:@selector(revealToggle:)];
    _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNote)];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MFNote" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *notes = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [MFNotesModel sharedModel].notesList = [notes mutableCopy];;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 60) style:UITableViewStylePlain];
    _tableView.rowHeight = 84.5;
    _tableView.backgroundColor = [UIColor colorWithPatternImage:listBackground];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    self.navigationItem.rightBarButtonItem = _addButton;
    [self.view addSubview:_tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _currentlyViewingNote = NO;
    
    [self.tableView reloadData];
    [revealController panGestureRecognizer].enabled = YES;
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if ([defaults boolForKey:@"firstTime"] == NO) {
//        [self presentFirstTimeView];
//    }
    
    self.navigationItem.title = @"Jott";
    [self.navigationController.navigationBar setBackgroundImage:navBarBackground
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:39.0/255.0 green:39.0/255.0 blue:39.0/255.0 alpha:0.5];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName : [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
                                                                      // [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0],
                                                                       NSShadowAttributeName : shadow,
                                                                      NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:30.0]
                                                                      }];
}

- (void)changeEncryptionFromOldPassword:(NSString *)oldPassword toNewPassword:(NSString *)newPassword; {
    for (MFNote *note in [[MFNotesModel sharedModel] notesList]) {
        note.text = [note.text AES256DecryptWithKey:oldPassword];
        note.text = [note.text AES256EncryptWithKey:newPassword];
    }
    [self.tableView reloadData];
}

- (void)addNote {
    anvc = [[MFAddNoteViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:anvc];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Present View Controllers

- (void)presentHomeViewController {
    if (self.presentedViewController) {
        [self dismissPresentedViewController];
    }
    [revealController revealToggle:self];
}

- (void)presentSettingsViewController {
    MFSettingsViewController *svc = [delegate settingsViewController];
    [svc.tableView setScrollEnabled:NO];
    
    [self.navigationController pushViewController:svc animated:YES];
    [revealController revealToggle:self];
}

- (void)presentUserSettingsViewController {
    MFUserSettingsViewController *usvc = [[MFUserSettingsViewController alloc]init];
    [self.navigationController pushViewController:usvc animated:YES];
    [revealController revealToggle:self];
}

- (void)presentInfoViewController {
    [revealController panGestureRecognizer].enabled = NO;
    MFInfoViewController *ivc = [[MFInfoViewController alloc] init];
    [self.navigationController pushViewController:ivc animated:YES];
    [revealController revealToggle:self];
}

- (void)presentViewNoteViewController {
    MFViewNoteViewController *vnc = [[MFViewNoteViewController alloc] init];
    [self.navigationController pushViewController:vnc animated:YES];
}

- (void)dismissPresentedViewController {
    [self.navigationController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
}

- (void)presentFirstTimeView {
    
    UIView *firstTimeView = [[UIView alloc] initWithFrame:CGRectMake(35, self.view.frame.size.height + 100, self.view.frame.size.width - 70, 130)];
    firstTimeView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.95];
    JCRBlurView *blur = [JCRBlurView new];
    [firstTimeView addSubview:blur];
    
    
    UIButton *setupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    setupButton.frame = CGRectMake(30, 240, 200, 50);
    setupButton.backgroundColor = [UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0];
    [setupButton setTitle:@"Setup Profile" forState:UIControlStateNormal];
    [setupButton addTarget:self action:@selector(setupButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 25, 250, 50)];
    welcomeLabel.text = @"Welcome to Jott!\n\n";
    welcomeLabel.backgroundColor = [UIColor clearColor];
    welcomeLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:22.0];
    welcomeLabel.textAlignment = NSTextAlignmentCenter;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 85, 245, 350)];
    textView.backgroundColor = [UIColor clearColor];
    textView.text = @"It looks this is your first time. \n Before you can add any notes, you will need to set up your profile.\n\n Tap the button below to get started.";
    textView.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
    textView.textAlignment = NSTextAlignmentCenter;
    
    [firstTimeView addSubview:welcomeLabel];
    [firstTimeView addSubview:textView];
    [firstTimeView addSubview:setupButton];
    [self.navigationController.view addSubview:firstTimeView];

    [UIView animateWithDuration:0.4
                          delay: 4.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         firstTimeView.frame = CGRectMake(30, 150, self.view.frame.size.width - 60, 310);
                     }
                     completion:nil];

}

- (void)setupButtonTapped:(id)sender {
    UIView *view = (UIView *)[sender superview];
    
    [UIView animateWithDuration:0.4
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         view.frame = CGRectMake(30, self.view.frame.size.height +150, self.view.frame.size.width - 60, self.view.frame.size.height - 150);
                     }
                     completion:^(BOOL finished) {
                         MFSettingsViewController *svc = [delegate settingsViewController];
                         [svc.tableView setScrollEnabled:NO];
                         
                         [self.navigationController pushViewController:svc animated:YES];
                         [view removeFromSuperview];
                     }];
}


#pragma mark - Table view data source

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollHeight = scrollView.contentOffset.y;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([[MFNotesModel sharedModel].notesList count] < 7) {
        self.navigationController.navigationBar.alpha = 1.0;
        if (scrollView.contentOffset.y > scrollHeight)
        {
            [scrollView setScrollEnabled:NO];
            [scrollView setContentOffset:CGPointMake(0, scrollHeight)];
        }
        [scrollView setScrollEnabled:YES];
    }
//    else if (scrollView.contentOffset.y > 0) {
//        self.navigationController.navigationBar.translucent = YES;
//        self.navigationController.navigationBar.alpha = 0.25;
//    }
//    else if (scrollView.contentOffset.y < 0) {
//        self.navigationController.navigationBar.translucent = NO;
//        self.navigationController.navigationBar.alpha = 1.0;
//    }
    
    
//    else {
//        if (scrollView.contentOffset.y >= 0.0)
//        {
//            self.navigationController.navigationBar.alpha = 0.5;
//        }
//        if (scrollView.contentOffset.y < 0.0)
//        {
//            self.navigationController.navigationBar.alpha = 1.0;
//        }
//    }
}

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
    _currentlyViewingNote = YES;
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
    
    cell.textLabel.textColor = [UIColor colorWithRed:60.0/255.0 green:125.0/255.0 blue:125.0/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:20.0];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14.0];
    cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.15];
    
    UIView *selectedView = [[UIView alloc] initWithFrame:cell.frame];
    selectedView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    cell.selectedBackgroundView = selectedView;
    
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

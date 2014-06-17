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
#import "FXBlurView.h"
#import "MFFacesListTableViewController.h"

@interface MFViewController ()

@end

@implementation UINavigationBar (customNav)
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(self.frame.size.width,45);
    return newSize;
}
@end

@implementation MFViewController {
    MFAppDelegate *delegate;
    CGFloat scrollHeight;
    UIImage *navBarBackground;
    UIView *dim;
    NSUserDefaults *defaults;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialSetup];
    [self.view addSubview:[MFCamera sharedCamera]];
//    [[MFCamera sharedCamera] pause];
}

- (void)initialSetup {
    
    defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"firstTime"] != NO) {
        [defaults setBool:NO forKey:@"firstTime"];
        [defaults setInteger:100 forKey:@"sensitivity"];
//        [defaults setInteger:0 forKey:@"textEncryption"];
//        [defaults setInteger:3 forKey:@"decryptTimer"];
        [self presentFirstTimeView];
    }
    [defaults setInteger:100 forKey:@"sensitivity"];


    _background = [UIImage imageNamed:@"paper2.png"];
    _background = [UIImage imageWithCGImage: [_background CGImage]
                        scale:(_background.scale * 2.1)
                  orientation:(_background.imageOrientation)];
    
    navBarBackground = [UIImage imageNamed:@"navBar.png"];
    navBarBackground = [UIImage imageWithCGImage:[navBarBackground CGImage]
                                         scale:(navBarBackground.scale * 2.5)
                                   orientation:(navBarBackground.imageOrientation)];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:_background];
    
    
    
    delegate = (MFAppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = delegate.managedObjectContext;
    
    _revealController = [self revealViewController];
    [_revealController panGestureRecognizer];
    [_revealController tapGestureRecognizer];
    self.revealViewController.delegate = self;
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu.png"]style:UIBarButtonItemStyleBordered target:_revealController action:@selector(revealToggle:)];
    _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentAddNoteViewController)];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MFNote" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *notes = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [MFNotesModel sharedModel].notesList = [notes mutableCopy];;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 60) style:UITableViewStylePlain];
    _tableView.rowHeight = 84.5;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    self.navigationItem.rightBarButtonItem = _addButton;
    [self.view addSubview:_tableView];
}

- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _currentlyViewingNote = NO;
    
    [self.tableView reloadData];
    [_revealController panGestureRecognizer].enabled = YES;
    
    [self.navigationController.navigationBar setBackgroundImage:navBarBackground forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    
    
    self.navigationItem.title = @"Jott";
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:39.0/255.0 green:39.0/255.0 blue:39.0/255.0 alpha:0.5];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName : [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
                                                                      // [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0],
                                                                      NSShadowAttributeName : shadow,
                                                                      NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:28.0]
                                                                      }];

}

- (void)changeEncryptionFromOldPassword:(NSString *)oldPassword toNewPassword:(NSString *)newPassword; {
    for (MFNote *note in [[MFNotesModel sharedModel] notesList]) {
        note.text = [note.text AES256DecryptWithKey:oldPassword];
        note.text = [note.text AES256EncryptWithKey:newPassword];
    }
    [self.tableView reloadData];
}

#pragma mark - Present View Controllers

- (void)presentHomeViewController {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [_revealController revealToggle:self];
}

- (void)presentSettingsViewController {
    
    NSArray *viewControllers = [[self navigationController] viewControllers];
    for( int i = 0; i < [viewControllers count]; i++){
        id vc = [viewControllers objectAtIndex:i];
        if([vc isKindOfClass:[MFSettingsViewController class]]){
            [[self navigationController] popToViewController:vc animated:YES];
            [_revealController revealToggle:self];
            return;
        }
    }
    
    MFSettingsViewController *svc = [delegate settingsViewController];
    [svc.tableView setScrollEnabled:NO];
    [self.navigationController pushViewController:svc animated:YES];
    [_revealController revealToggle:self];
}

- (void)presentUserSettingsViewController {
    
    NSArray *viewControllers = [[self navigationController] viewControllers];
    for( int i = 0; i < [viewControllers count]; i++){
        id vc = [viewControllers objectAtIndex:i];
        if([vc isKindOfClass:[MFUserSettingsViewController class]]){
            [[self navigationController] popToViewController:vc animated:YES];
            [_revealController revealToggle:self];
            return;
        }
    }
    
    MFUserSettingsViewController *usvc = [[MFUserSettingsViewController alloc]init];
    [self.navigationController pushViewController:usvc animated:YES];
    [_revealController revealToggle:self];
}

- (void)presentInfoViewController {

    NSArray *viewControllers = [[self navigationController] viewControllers];
    for( int i = 0; i < [viewControllers count]; i++){
        id vc = [viewControllers objectAtIndex:i];
        if([vc isKindOfClass:[MFInfoViewController class]]){
            [[self navigationController] popToViewController:vc animated:YES];
            [_revealController revealToggle:self];
            return;
        }
    }
    
    MFInfoViewController *ivc = [[MFInfoViewController alloc] init];
    [self.navigationController pushViewController:ivc animated:YES];
    [_revealController revealToggle:self];
}

- (void)presentViewNoteViewController {
    [_revealController panGestureRecognizer].enabled = NO;
    MFViewNoteViewController *vnvc = [[MFViewNoteViewController alloc] init];
    vnvc.currentNote = _currentNote;
    [self.navigationController pushViewController:vnvc animated:YES];
}

- (void)presentFacesListViewController {
    NSArray *viewControllers = [[self navigationController] viewControllers];
    for( int i = 0; i < [viewControllers count]; i++){
        id vc = [viewControllers objectAtIndex:i];
        if([vc isKindOfClass:[MFFacesListTableViewController class]]){
            [[self navigationController] popToViewController:vc animated:YES];
            [_revealController revealToggle:self];
            return;
        }
    }
    
    MFFacesListTableViewController *flvc = [[MFFacesListTableViewController alloc] init];
    [self.navigationController pushViewController:flvc animated:YES];
    [_revealController revealToggle:self];
}

- (void)presentAddNoteViewController {
    
    if ([delegate.password isEqualToString:@""]) {
        UIAlertView *noPasswordAlertView = [[UIAlertView alloc] initWithTitle:@"No Password"
                                                                      message:@"Please set a password first"
                                                                     delegate:self
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil, nil];
        [noPasswordAlertView show];
        return;
    }
    
    [_revealController panGestureRecognizer].enabled = NO;
    MFAddNoteViewController *anvc = [[MFAddNoteViewController alloc] init];
    [self.navigationController pushViewController:anvc animated:YES];
}

- (void)dismissPresentedViewController {
    [self.navigationController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
}

- (void)presentFirstTimeView {

    UIView *firstTimeView = [[UIView alloc] initWithFrame:CGRectMake(35, self.view.frame.size.height + 100, self.view.frame.size.width - 50, 160)];
    firstTimeView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.95];
    
    //    JCRBlurView *blur = [JCRBlurView new];
//    [firstTimeView addSubview:blur];
    
    
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
    textView.editable = NO;
    
    [firstTimeView addSubview:welcomeLabel];
    [firstTimeView addSubview:textView];
    [firstTimeView addSubview:setupButton];
    [self.navigationController.view addSubview:firstTimeView];

    [UIView animateWithDuration:0.4
                          delay: 4.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         firstTimeView.frame = CGRectMake(30, 130, self.view.frame.size.width - 60, 310);
                     }
                     completion:^(BOOL finished) {
                         [self animateDim];
                         [self.view bringSubviewToFront:firstTimeView];
                     }];

}

- (void)animateDim {
    dim = [[UIView alloc] initWithFrame:self.view.bounds];
    dim.backgroundColor = [UIColor blackColor];
    dim.alpha = 0.0;
    [self.view addSubview:dim];
    
    [UIView animateWithDuration:0.5
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         dim.alpha = 0.5;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
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
                         [dim removeFromSuperview];
                     }];
}


#pragma mark - TableView Delegate Methods

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
    cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6];
    
    UIView *selectedView = [[UIView alloc] initWithFrame:cell.frame];
    selectedView.backgroundColor = [UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:0.6];
    cell.selectedBackgroundView = selectedView;
    
    
    cell.textLabel.text = [[[MFNotesModel sharedModel].notesList objectAtIndex:[indexPath row]] title];

    if ([defaults integerForKey:@"textEncryption"] == 0) {
        cell.detailTextLabel.text = [[[MFNotesModel sharedModel].notesList objectAtIndex:[indexPath row]] text];
    }
    else if ([defaults integerForKey:@"textEncryption"] == 1) {
        cell.detailTextLabel.text = [[[[MFNotesModel sharedModel].notesList objectAtIndex:[indexPath row]] text] AES256DecryptWithKey:delegate.password];
        
//        UIView *blur = [[UIView alloc] initWithFrame:CGRectMake(15, 43, 290, 30)];
//        blur.backgroundColor = [UIColor whiteColor];
//        blur.alpha = 0.9;
//        [cell.contentView addSubview:blur];
//        [cell.contentView addSubview:blur];
    }
    else if ([defaults integerForKey:@"textEncryption"] == 2) {
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

- (void)deleteAllNotes {
    
    for (MFNote *note in [MFNotesModel sharedModel].notesList) {
        [_managedObjectContext deleteObject:note];
    }
    [_managedObjectContext save:nil];    
    
    [[MFNotesModel sharedModel].notesList removeAllObjects];
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

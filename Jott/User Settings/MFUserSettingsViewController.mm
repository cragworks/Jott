//
//  MFUserSettingsViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 5/29/14.
//
//

#import "MFUserSettingsViewController.h"
#import "MFAppDelegate.h"

@interface MFUserSettingsViewController ()

@end

@implementation MFUserSettingsViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
    
    MFAppDelegate *appDelegate = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
    self.view.backgroundColor = [UIColor colorWithPatternImage:appDelegate.root.background];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 450)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.scrollEnabled = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
   // self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated {
    //self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close {
    MFAppDelegate *appDelegate = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.root dismissPresentedViewController];
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 55.0;
}



- (UIView *)tableView:(UITableView *)tableview viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableview.bounds.size.width, 60)];
    view.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:255.0/255.0 alpha:1.0];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 32, 320, 20);
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    label.text = [[self tableView:self.tableView titleForHeaderInSection:section] uppercaseString];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:label];
    
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 4;
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"Encrypted Text View";
    }
    return @"Decrypt Button Duration";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
       [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 1) {
        if (cell.accessoryType == UITableViewCellAccessoryNone) cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"5 Minutes";
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"15 Minutes";
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = @"30 Minutes";
        }
        else if (indexPath.row == 3) {
            cell.textLabel.text = @"Until Closed";
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Encrypted String";
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"Blur";
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = @"Invisible";
        }
    }
    
    return cell;
}

@end

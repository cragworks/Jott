//
//  MFSettingsViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 5/22/14.
//
//

#import <Security/Security.h>

#import "MFSettingsViewController.h"
#import "MFKeychainWrapper.h"
#import "MFSetPasswordViewController.h"
#import "MFViewController.h"
#import "MFSetFaceViewController.h"
#import "MFFacesListTableViewController.h"
#import "MFAppDelegate.h"
#import "MFNotesModel.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

enum {
	kUsernameSection = 0,
	kPasswordSection,
    faceRecognitionSection,
    sensitivitySection,
    resetPasswordSection
};

static NSInteger kPasswordTag	= 2;	// Tag table view cells that contain a text field to support secure text entry.

@implementation MFSettingsViewController

@synthesize tableView, passwordItem;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialSetup];
}

- (void) initialSetup {
    
    _setUsernameViewController = [[MFSetUsernameViewController alloc] init];
    _setPasswordViewController = [[MFSetPasswordViewController alloc] init];
    
    self.title = @"Settings";
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:255.0/255.0 alpha:1.0];
    
    _enterPasswordAlertView = [[UIAlertView alloc] init];
    _enterPasswordAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    _enterPasswordAlertView.title = @"Enter Password";
    _enterPasswordAlertView.message = @"Enter your current password to change to a new password.";
    _enterPasswordAlertView.delegate = self;
    [_enterPasswordAlertView textFieldAtIndex:0].clearsOnBeginEditing = YES;
    _enterPasswordAlertView.tag = 1;
    [_enterPasswordAlertView addButtonWithTitle:@"Enter"];
    
    textFieldController = [[MFSetPasswordViewController alloc] init];
    
    _needsAuthentication = YES;
    
    [self sliderSetup];
    
    [self.view addSubview:tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!IS_IPHONE_5) [tableView setScrollEnabled:YES];
    else tableView.scrollEnabled = NO;
    
    [self sliderSetup];
    
    [tableView reloadData];
}

- (void)sliderSetup {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults integerForKey:@"sensitivity"] == 0) _slider.value = 10;
    else _slider.value = [defaults integerForKey:@"sensitivity"];
    _slider.userInteractionEnabled = YES;
    currentThreshold = [MFCamera sharedCamera].confidenceThreshhold - _slider.value;
}

- (void) back {
    MFAppDelegate *appDelegate = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.root dismissPresentedViewController];
}

+ (NSString *)titleForSection:(NSInteger)section
{
    switch (section)
    {
        case kUsernameSection: return NSLocalizedString(@"Name", @"");
        case kPasswordSection: return NSLocalizedString(@"Password", @"");
        case sensitivitySection: return NSLocalizedString(@"Recognition Sensitivity", @"");
    }
    return nil;
}

+ (id)secAttrForSection:(NSInteger)section
{
    switch (section)
    {
        case kUsernameSection: return (__bridge id)kSecAttrAccount;
        case kPasswordSection: return (__bridge id)kSecValueData;
    }
    return nil;
}

- (void)switchAction:(id)sender
{
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:
							 [NSIndexPath indexPathForRow:0 inSection:kPasswordSection]];
	UITextField *textField = (UITextField *) [cell.contentView viewWithTag:kPasswordTag];
	textField.secureTextEntry = ![sender isOn];
	
	textField = (UITextField *) [cell.contentView viewWithTag:kPasswordTag];
	textField.secureTextEntry = ![sender isOn];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [passwordItem resetKeychainItem];
        [self.tableView reloadData];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [tableView reloadData];
}

#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 60;
    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == faceRecognitionSection || section == resetPasswordSection) ? 30.0 : 55.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return (section == resetPasswordSection) ? 100.0 : 0.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [MFSettingsViewController titleForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == faceRecognitionSection || indexPath.section == resetPasswordSection) return 50.0;
    return 45.0;
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

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kUsernameCellIdentifier =       @"UsernameCell";
	static NSString *kPasswordCellIdentifier =       @"PasswordCell";
    static NSString *sensitivityCellIdentifier =     @"Sensitivity";
    static NSString *faceRecognitionCellIdentifier = @"faceRecognition";
	static NSString *resetEverythingCellIdentifier = @"resetEverything";
    
	UITableViewCell *cell = nil;
	
	switch (indexPath.section)
	{
		case kUsernameSection:
		{
			cell = [aTableView dequeueReusableCellWithIdentifier:kUsernameCellIdentifier];
			if (cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kUsernameCellIdentifier];
			}
			
			cell.textLabel.text = [passwordItem objectForKey:[MFSettingsViewController secAttrForSection:indexPath.section]];
			cell.accessoryType = (self.editing) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
			
			break;
		}
			
		case kPasswordSection:
		{
			UITextField *textField = nil;
			
			cell = [aTableView dequeueReusableCellWithIdentifier:kPasswordCellIdentifier];
			if (cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPasswordCellIdentifier];
                
				textField = [[UITextField alloc] initWithFrame:CGRectInset(cell.contentView.bounds, 10, 10)];
				textField.tag = kPasswordTag;
				textField.font = [UIFont systemFontOfSize:17.0];
				textField.enabled = NO;
				textField.secureTextEntry = YES;
                textField.clearsOnBeginEditing = YES;
				
				[cell.contentView addSubview:textField];
			}
			else {
				textField = (UITextField *) [cell.contentView viewWithTag:kPasswordTag];
			}
			
            MFKeychainWrapper *wrapper = passwordItem;
			textField.text = [wrapper objectForKey:[MFSettingsViewController secAttrForSection:indexPath.section]];
			cell.accessoryType = (self.editing) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
            
			break;
		}
        case sensitivitySection:
		{
			cell = [aTableView dequeueReusableCellWithIdentifier:sensitivityCellIdentifier];
			if (cell == nil)
			{
                
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sensitivityCellIdentifier];
                
				_slider = [[UISlider alloc] initWithFrame:CGRectMake(cell.frame.size.width/2-100, cell.frame.size.height/2-10, 200, 20)];
                [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
                
                _slider.maximumValue = 15;
                _slider.minimumValue = 5;
                _slider.userInteractionEnabled = YES;
                
				cell.selectionStyle = UITableViewCellSelectionStyleNone;

                UILabel *less = [[UILabel alloc] initWithFrame:CGRectMake(25, cell.frame.size.height/2 - 10, 100, 20)];
                less.text = @"LESS";
                less.font = [UIFont fontWithName:@"Helvetica Neue" size:10.0];
                
                UILabel *more = [[UILabel alloc] initWithFrame:CGRectMake(270, cell.frame.size.height/2 - 10, 100, 20)];
                more.text = @"MORE";
                more.font = [UIFont fontWithName:@"Helvetica Neue" size:10.0];
                
                [cell.contentView addSubview:more];
                [cell.contentView addSubview:less];
                [cell.contentView addSubview:_slider];
			}
			
			break;
		}
        case faceRecognitionSection:
        {
            cell = [aTableView dequeueReusableCellWithIdentifier:faceRecognitionCellIdentifier];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:faceRecognitionCellIdentifier];
            }
            cell.textLabel.text = @"Set Face Recognition";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            break;
        }
        case resetPasswordSection:
        {
            cell = [aTableView dequeueReusableCellWithIdentifier:resetEverythingCellIdentifier];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resetEverythingCellIdentifier];
            }
            cell.textLabel.text = @"Reset Password";
            
            break;
        }
        default:
        {
            
        }
	}
    
	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == kPasswordSection)
	{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if ([[passwordItem objectForKey:(__bridge id)kSecValueData] isEqualToString:@""]) {
            _needsAuthentication = NO;
        }
        
        if (_needsAuthentication) [_enterPasswordAlertView show];
        else {
            _needsAuthentication = YES;
            id secAttr = [MFSettingsViewController secAttrForSection:indexPath.section];
            [_setPasswordViewController.textControl setSecureTextEntry:(indexPath.section == kPasswordSection)];
            _setPasswordViewController.keychainWrapper = passwordItem;
            _setPasswordViewController.editedFieldKey = secAttr;
            _setPasswordViewController.title = [MFSettingsViewController titleForSection:indexPath.section];
            
            [self.navigationController pushViewController:_setPasswordViewController animated:YES];
        }
	}
    else if (indexPath.section == kUsernameSection) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        id secAttr = [MFSettingsViewController secAttrForSection:indexPath.section];
        [_setUsernameViewController.textControl setPlaceholder:[MFSettingsViewController titleForSection:indexPath.section]];
        _setUsernameViewController.keychainWrapper = passwordItem;
        _setUsernameViewController.editedFieldKey = secAttr;
        
        [self.navigationController pushViewController:_setUsernameViewController animated:YES];
    }
    else if (indexPath.section == sensitivitySection) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }
    else if (indexPath.section == faceRecognitionSection) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        if ([[passwordItem objectForKey:(__bridge id)kSecValueData] isEqualToString:@""]) {
            UIAlertView *noPasswordAlertView = [[UIAlertView alloc] initWithTitle:@"No Password"
                                                                          message:@"Please set a password first"
                                                                         delegate:self
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil, nil];
            [noPasswordAlertView show];
            return;
        }
        
        MFFacesListTableViewController *facesList = [[MFFacesListTableViewController alloc] init];
        [self.navigationController pushViewController:facesList animated:YES];
        
    }
    else if (indexPath.section == resetPasswordSection) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        UIAlertView *resetAlert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                             message:@"Reseting will erase the username, password, and all of the current notes and faces.\nAre you sure you want to do this?"
                                                            delegate:self
                                                   cancelButtonTitle:@"No"
                                                   otherButtonTitles:@"Yes", nil];
        resetAlert.tag = 3;
        [resetAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        MFAppDelegate *appDelegate = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
        
        if ([[alertView textFieldAtIndex:0].text isEqualToString: appDelegate.password]) {
            _needsAuthentication = NO;
            NSIndexPath *path = [[NSIndexPath alloc] initWithIndex:1];
            [self tableView:self.tableView didSelectRowAtIndexPath:path];
        }
    }
    else if (alertView.tag == 2) {
        MFSetFaceViewController *sfvc = [[MFSetFaceViewController alloc] init];
        [self.navigationController pushViewController:sfvc animated:YES];
    }
    else if (alertView.tag == 3) {
        if (buttonIndex == 1) [self resetEverything];
    }
}

- (void)resetEverything {
    [passwordItem setObject:@"" forKey:(__bridge id)kSecValueData];
    [passwordItem setObject:@"" forKey:(__bridge id)kSecAttrAccount];
    
    MFAppDelegate *appDelegate = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate refreshPassword];
    [appDelegate.root deleteAllNotes];
    
    CustomFaceRecognizer *faceRecognizer = [[CustomFaceRecognizer alloc] init];
    MFFacesListTableViewController *flvc = [[MFFacesListTableViewController alloc] init];
    [flvc removeAllFacesFromFaceRecognizer:faceRecognizer];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)sliderValueChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:slider.value forKey:@"sensitivity"];
}

//- (void)calibrateSlider:(NSInteger)val {
// 
//    NSInteger max = (val + 10) + 5;
//    if (max > 100) max = 100;
//    
//    NSInteger min = (val + 10) - 5;
//    if (max < 60) max = 60;
//    
//    _slider.minimumValue = min;
//    _slider.maximumValue = max;
//    [_slider setValue:val];
//}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [MFCamera sharedCamera].confidenceThreshhold = currentThreshold + _slider.value;
    
}

@end

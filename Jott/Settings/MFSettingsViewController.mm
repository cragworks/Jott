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
#import "MFAppDelegate.h"

enum {
	kUsernameSection = 0,
	kPasswordSection,
	kShowCleartextSection,
    faceRecognition
};

// Defined UI constants.
static NSInteger kPasswordTag	= 2;	// Tag table view cells that contain a text field to support secure text entry.

@implementation MFSettingsViewController

@synthesize tableView, textFieldController, passwordItem;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialSetup];
}

- (void) initialSetup {
    self.title = @"Settings";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:255.0/255.0 alpha:1.0];
    tableView.scrollEnabled = NO;
    
    textFieldController = [[MFSetPasswordViewController alloc] init];

    [self.view addSubview:tableView];
    self.navigationItem.leftBarButtonItem = back;
}

- (void) back {
    MFAppDelegate *appDelegate = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.root dismissPresentedViewController];
}

+ (NSString *)titleForSection:(NSInteger)section
{
    switch (section)
    {
        case kUsernameSection: return NSLocalizedString(@"Username", @"");
        case kPasswordSection: return NSLocalizedString(@"Password", @"");
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tableView reloadData];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [tableView reloadData];
}

#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return (section == kShowCleartextSection) ? 0.0 : 60.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return (section == 3) ? 60.0 : 0.0;;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [MFSettingsViewController titleForSection:section];
}

//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
//{
//    NSString *title = nil;
//	
//	if (section == kAccountNumberSection)
//	{
//		title = NSLocalizedString(@"AccountNumberShared", @"");
//	}
//	
//	return title;
//}

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
	static NSString *kUsernameCellIdentifier =  @"UsernameCell";
	static NSString *kPasswordCellIdentifier =  @"PasswordCell";
	static NSString *kSwitchCellIdentifier =    @"SwitchCell";
	
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
        case kShowCleartextSection:
		{
			cell = [aTableView dequeueReusableCellWithIdentifier:kSwitchCellIdentifier];
			if (cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSwitchCellIdentifier];
				
				cell.textLabel.text = NSLocalizedString(@"Show Password", @"");
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
				UISwitch *switchCtl = [[UISwitch alloc] initWithFrame:CGRectMake(240, 8, 94, 27)];
				[switchCtl addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
				[cell.contentView addSubview:switchCtl];
			}
			
			break;
		}
        default:
        {
            cell = [aTableView dequeueReusableCellWithIdentifier:kUsernameCellIdentifier];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kUsernameCellIdentifier];
            }
            cell.textLabel.text = @"Set Face Recognition";
        }
	}
    
	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == kPasswordSection || indexPath.section == kUsernameSection)
	{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		id secAttr = [MFSettingsViewController secAttrForSection:indexPath.section];
		[textFieldController.textControl setPlaceholder:[MFSettingsViewController titleForSection:indexPath.section]];
		[textFieldController.textControl setSecureTextEntry:(indexPath.section == kPasswordSection)];
        textFieldController.keychainWrapper = passwordItem;
        
		if (indexPath.section == kUsernameSection)  {
            textFieldController.textValue = [textFieldController.keychainWrapper objectForKey:secAttr];
            textFieldController.setPassword = NO;
        }
        else textFieldController.setPassword = YES;
        
		textFieldController.editedFieldKey = secAttr;
		textFieldController.title = [MFSettingsViewController titleForSection:indexPath.section];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:5.0/255.0 green:155.0/255.0 blue:250.0/255.0 alpha:1.0];
        self.navigationController.navigationBar.translucent = NO;

		[self.navigationController pushViewController:textFieldController animated:YES];
	}
    else if (indexPath.section != kShowCleartextSection) {
        MFSetFaceViewController *setFaceViewController = [[MFSetFaceViewController alloc]init];
        [self.navigationController pushViewController:setFaceViewController animated:YES];
    }
}

@end

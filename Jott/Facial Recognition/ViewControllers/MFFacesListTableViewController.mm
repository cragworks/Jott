//
//  MFFacesListTableViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 6/10/14.
//
//

#import "MFFacesListTableViewController.h"
#import "MFSetFaceViewController.h"
#import "CustomFaceRecognizer.h"
#import "MFAppDelegate.h"

@interface MFFacesListTableViewController ()

@end

@implementation MFFacesListTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 56;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFace)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _addFaceAlertView = [[UIAlertView alloc] init];
    _addFaceAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    _addFaceAlertView.title = @"Enter Password";
    _addFaceAlertView.message = @"Enter master password to add a new face";
    _addFaceAlertView.delegate = self;
    _addFaceAlertView.tag = 1;
    [_addFaceAlertView addButtonWithTitle:@"Enter"];
    
    _deleteFaceAlertView = [[UIAlertView alloc] init];
    _deleteFaceAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    _deleteFaceAlertView.title = @"Enter Password";
    _deleteFaceAlertView.message = @"Enter master password to delete a face";
    _deleteFaceAlertView.delegate = self;
    _deleteFaceAlertView.tag = 2;
    [_deleteFaceAlertView addButtonWithTitle:@"Enter"];
    
    _faces = [[NSMutableArray alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
    _faceRecognizer = [[CustomFaceRecognizer alloc] init];
    _faces = [_faceRecognizer getAllPeople];

    self.navigationItem.title = @"Faces";
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:39.0/255.0 green:39.0/255.0 blue:39.0/255.0 alpha:0.5];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName : [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
                                                                      // [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0],
                                                                      NSShadowAttributeName : shadow,
                                                                      NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:28.0]
                                                                      }];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addFace {
    [_addFaceAlertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        MFAppDelegate *appDelegate = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
        if ([[alertView textFieldAtIndex:0].text isEqualToString: appDelegate.password]) {
            MFSetFaceViewController *sfvc = [[MFSetFaceViewController alloc] init];
            [self.navigationController pushViewController:sfvc animated:YES];
        }
    }
    else if (alertView.tag == 2) {
        MFSetFaceViewController *sfvc = [[MFSetFaceViewController alloc] init];
        [self.navigationController pushViewController:sfvc animated:YES];
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_faces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    _selectedFace = [_faces objectAtIndex:indexPath.row];
    cell.textLabel.text = [_selectedFace objectForKey:@"name"];
    cell.textLabel.textColor = [UIColor colorWithRed:65.0/255.0 green:155.0/255.0 blue:155.0/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:20.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
 
        _faceRecognizer = [[CustomFaceRecognizer alloc] init];
        _faces = [_faceRecognizer getAllPeople];
        
        //[_deleteFaceAlertView show];
        _selectedFace = [_faces objectAtIndex:indexPath.row];
        [_faceRecognizer removePersonForName:[_selectedFace objectForKey:@"name"]];
        [_faces removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


- (void)removeAllFacesFromFaceRecognizer:(CustomFaceRecognizer *)faceRecognizer {

    NSMutableArray *faces = [faceRecognizer getAllPeople];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (int i = 0; i < [faces count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        [indexPaths addObject:indexPath];
        [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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

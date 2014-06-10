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
    
    _faceRecognizer = [[CustomFaceRecognizer alloc] init];
    
    self.tableView.rowHeight = 75;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFace)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _faces = [[NSMutableArray alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _faces = [_faceRecognizer getAllPeople];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addFace {
    MFSetFaceViewController *sfvc = [[MFSetFaceViewController alloc] init];
    [self.navigationController pushViewController:sfvc animated:YES];
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

   // [self performSegueWithIdentifier:@"CaptureImages" sender:self];
    
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
    _selectedFace = [_faces objectAtIndex:indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
      //  [_faceRecognizer removeFaceForPersonID:indexPath.row+1];
//         NSLog(@"Before Selected = %@\n\n\n\n",_selectedFace);
//        NSLog(@"Before Faces = %@\n\n\n\n",_faces);
        [_faceRecognizer removePersonForName:[_selectedFace objectForKey:@"name"]];
        //[_faceRecognizer forgetAllFacesForPersonID:indexPath.row+1];
        [_faces removeObjectAtIndex:indexPath.row];
//         NSLog(@"After Selected = %@",_selectedFace);
//        NSLog(@"After Faces = %@\n\n\n\n",_faces);
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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

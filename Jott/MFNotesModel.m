//
//  MFNotesModel.m
//  Jott
//
//  Created by Mohssen Fathi on 5/16/14.
//
//

#import "MFNotesModel.h"
#import "MFViewController.h"
#import "MFNote.h"

@implementation MFNotesModel

static MFNotesModel *sharedNotesModel = nil;
+ (MFNotesModel *)sharedModel {
    if (sharedNotesModel == nil) {
        sharedNotesModel = [[super allocWithZone:NULL] init];
        sharedNotesModel.notesList = [[NSMutableArray alloc] init];
    }
    return sharedNotesModel;
}

- (void) addNote:(MFNote *)note {
    [_notesList addObject:note];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"%lu\n",[_notesList count]);
    return [_notesList count];
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
    
    cell.textLabel.text = [[_notesList objectAtIndex:(NSUInteger)indexPath] description];
    
    return cell;
}

@end

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
    [_notesList insertObject:note atIndex:0];
}

@end

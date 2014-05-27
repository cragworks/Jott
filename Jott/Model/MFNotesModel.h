//
//  MFNotesModel.h
//  Jott
//
//  Created by Mohssen Fathi on 5/16/14.
//
//

#import <Foundation/Foundation.h>
#import "MFNote.h"

@interface MFNotesModel : NSObject

@property (nonatomic, strong) NSMutableArray *notesList;

- (void) addNote:(MFNote *)note;
+ (MFNotesModel *)sharedModel;

@end

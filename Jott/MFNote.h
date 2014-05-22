//
//  MFNote.h
//  Jott
//
//  Created by Mohssen Fathi on 5/16/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MFNote : NSManagedObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray *canView;
@property (nonatomic, assign) BOOL isEncrypted;

@end

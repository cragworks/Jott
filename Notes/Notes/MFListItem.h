//
//  MFListItem.h
//  Notes
//
//  Created by Mohssen Fathi on 5/13/14.
//
//

#import <Foundation/Foundation.h>

@interface MFListItem : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray *canView;

@end

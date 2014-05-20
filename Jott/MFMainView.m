//
//  MFMainView.m
//  Jott
//
//  Created by Mohssen Fathi on 5/16/14.
//
//

#import "MFMainView.h"
#import "MFViewController.h"

@implementation MFMainView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
         _tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, self.frame.size.height*0.1, self.frame.size.width - 20, self.frame.size.height*0.8) style:UITableViewStylePlain];
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addButton.frame = CGRectMake(self.frame.size.width - 45, 30, 30, 30);
        [_addButton setImage:[UIImage imageNamed:@"plus-50.png"] forState:UIControlStateNormal];
        
        [self addSubview:_addButton];
        [self addSubview:_tableView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

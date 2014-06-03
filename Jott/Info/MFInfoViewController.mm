//
//  MFInfoViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 5/28/14.
//
//

#import "MFInfoViewController.h"
#import "MFInfoChildViewController.h"
#import "MFAppDelegate.h"

@interface MFInfoViewController ()

@end

@implementation MFInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initialSetup];
    
}

- (void)initialSetup {    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    self.pageController.view.frame = self.view.bounds;
    
    MFInfoChildViewController *initialViewController = [self viewControllerAtIndex:0];
    initialViewController.view.backgroundColor = [UIColor grayColor];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [self.view addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

- (void)close {
    MFAppDelegate *appDelegate = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.root dismissPresentedViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(MFInfoChildViewController *)viewController index];
    if (index == 0) return nil;
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(MFInfoChildViewController *)viewController index];
    index++;
    if (index == 5) return nil;
    
    return [self viewControllerAtIndex:index];
}

- (MFInfoChildViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    MFInfoChildViewController *childViewController = [[MFInfoChildViewController alloc] init];
    childViewController.index = index;
    
    return childViewController;
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 5;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

@end

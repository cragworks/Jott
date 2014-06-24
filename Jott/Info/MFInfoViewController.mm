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
    self.pageController.delegate = self;
    self.pageController.view.frame = self.view.bounds;
    
    self.navigationItem.title = @"Welcome to Jott!";
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    
    MFInfoChildViewController *initialViewController = [self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageController.view.backgroundColor = [UIColor clearColor];

    
    self.view.backgroundColor = [UIColor whiteColor];
    [self addChildViewController:self.pageController];
    [self.view addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName : [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
                                                                      NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:24.0]
                                                                      }];
    
    MFAppDelegate *appDelegate = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.root.revealController panGestureRecognizer].enabled = NO;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gesture
{
//    UIViewAnimationOptions option = kNilOptions;
//    
//    if (gesture.direction == UISwipeGestureRecognizerDirectionRight)
//    {
//        // if we're at the first card, don't do anything
//        
//        if (self.imageIndex == 0)
//            return;
//        
//        // if swiping to the right, maybe it's like putting a card
//        // back on the top of the deck of cards
//        
//        option = UIViewAnimationOptionTransitionCurlDown;
//        
//        // adjust the index of the next card to be shown
//        
//        self.imageIndex--;
//    }
//    else if (gesture.direction == UISwipeGestureRecognizerDirectionLeft)
//    {
//        // if we're at the last card, don't do anything
//        
//        if (self.imageIndex == ([self.imageNames count] - 1))
//            return;
//        
//        // if swiping to the left, it's like pulling a card off the
//        // top of the deck of cards
//        
//        option = UIViewAnimationOptionTransitionCurlUp;
//        
//        // adjust the index of the next card to be shown
//        
//        self.imageIndex++;
//    }
//    
//    // now animate going to the next card; the view you apply the
//    // animation to is the container view that is holding the image
//    // view. In this example, I have the image view on the main view,
//    // but if you want to constrain the animation to only a portion of
//    // the screen, you'd define a simple `UIView` that is the dimensions
//    // that you want to animate and then put the image view inside
//    // that view, and replace the `self.view` reference below with the
//    // view that contains the image view.
//    
//    [UIView transitionWithView:self.view
//                      duration:0.5
//                       options:option
//                    animations:^{
//                        self.imageView.image = [UIImage imageWithContentsOfFile:self.imageNames[self.imageIndex]];
//                    }
//                    completion:nil];
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

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    UIViewController* vc = self.pageController.viewControllers[0];
    self.navigationItem.title = vc.navigationItem.title;
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
//    self.navigationItem.title = [NSString stringWithFormat:@"%lu",(unsigned long)index+1];
    
    return childViewController;
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 5;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

@end

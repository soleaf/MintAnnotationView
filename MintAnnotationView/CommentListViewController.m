//
//  CommentListViewController.m
//  MintAnnotationView
//
//  Created by soleaf on 13. 8. 26..
//  Copyright (c) 2013년 mintcode.org. All rights reserved.
//

#import "CommentListViewController.h"

@interface CommentListViewController ()

@end

@implementation CommentListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *firstMemo = @"<u uid=0>Mary</u> hi mary!!. I'm <u uid=1>Cloud</u>.";
    [self.memo annotationWithMemo:firstMemo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMemo:nil];
    [super viewDidUnload];
}
@end

//
//  ViewController.m
//  MintAnnotationView
//
//  Created by soleaf on 13. 8. 26..
//  Copyright (c) 2013년 mintcode.org. All rights reserved.
//

#import "ViewController.h"

#import "WriteViewController.h"
#import "CommentListViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (IBAction)goToWrite:(id)sender {
    
    WriteViewController *view = [[WriteViewController alloc] initWithNibName:@"WriteViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:YES];
    
}
- (IBAction)goToCommentView:(id)sender {
    
    CommentListViewController *view = [[CommentListViewController alloc] initWithNibName:@"CommentListViewController" bundle:nil];
    [self.navigationController pushViewController:view animated:YES];
}

@end

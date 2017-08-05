//
//  CommentListViewController.m
//  MintAnnotationView
//
//  Created by soleaf on 13. 8. 26..
//  Copyright (c) 2013년 mintcode.org. All rights reserved.
//

#import "CommentListViewController.h"

@interface CommentListViewController () <MintAnnotationMemoViewDelegate>

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
    
    self.title = @"CommentView";
    
    // Some custom apperances
    self.memo.nameTagImage = [[UIImage imageNamed:@"tagImage"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    self.memo.nameTagColor = [UIColor colorWithRed:0.00 green:0.54 blue:0.50 alpha:1.0];
    
    // Annotating With Tag <u>
    NSString *firstMemo = @"<u uid=0>Mary</u> hi mary!!. I'm <u uid=1>Cloud</u>.";
    [self.memo annotationWithMemo:firstMemo];
    
    // You may should it.
    self.memo.editable = NO;
    
    // If you want touch event on tags, Implement MintAnnotationViewDelegate
    self.memo.delegate = self;
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

// MintAnnotationView Event
- (void)touchedMintAnnotationTag:(NSString *)tagNameText
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"value"
                                                    message:tagNameText
                                                   delegate:nil
                                          cancelButtonTitle:@"Cacnel" otherButtonTitles:@"OK", nil];
    [alert show];
}

@end

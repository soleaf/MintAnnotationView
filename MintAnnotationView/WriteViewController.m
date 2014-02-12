//
//  WriteViewController.m
//  MintAnnotationView
//
//  Created by soleaf on 13. 8. 26..
//  Copyright (c) 2013년 mintcode.org. All rights reserved.
//

#import "WriteViewController.h"

@interface WriteViewController ()

@end

@implementation WriteViewController

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
    // Required
    // MintAnnotationChatView
    self.annotationView.delegate = self;
    
    // Some custom apperances
    self.annotationView.nameTagImage = [[UIImage imageNamed:@"tagImage"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    self.annotationView.nameTagColor = [UIColor colorWithRed:0.00 green:0.54 blue:0.50 alpha:1.0];
    
//    NSString *textWIthTag = @"hello <u uid=112>tester</u>:what are you doing <u uid=222>tes22ter</u>:what are you doing";
//    [self.annotationView setTextWithTageedString:textWIthTag];
}

- (IBAction)annotateMary:(id)sender {
    
    MintAnnotation *newAnnoation = [[MintAnnotation alloc] init];
    newAnnoation.usr_id = @"1";
    newAnnoation.usr_name = @"Mary";
    [self.annotationView addAnnotation:newAnnoation];
    
}

- (IBAction)annotateJames:(id)sender {
    
    MintAnnotation *newAnnoation = [[MintAnnotation alloc] init];
    newAnnoation.usr_id = @"2";
    newAnnoation.usr_name = @"James";
    [self.annotationView addAnnotation:newAnnoation];
    
}

- (IBAction)annotateSally:(id)sender {

    MintAnnotation *newAnnoation = [[MintAnnotation alloc] init];
    newAnnoation.usr_id = @"3";
    newAnnoation.usr_name = @"Sally";
    [self.annotationView addAnnotation:newAnnoation];

}

- (IBAction)getStringTag:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"value"
                                                    message:[self.annotationView makeStringWithTag]
                                                   delegate:nil
                                          cancelButtonTitle:@"aaa"
                                          otherButtonTitles:@"bbb", nil];
    [alert show];
}

#pragma mark - UITextViewDelegate (Required)

- (void)textViewDidChange:(UITextView *)textView
{
    // Checking User trying to remove MintAnnotationView's annoatation
    [self.annotationView textViewDidChange:textView];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // Checking User trying to edit MintAnnotationView's annoatation
    return [self.annotationView textView:textView shouldChangeTextInRange:range replacementText:text];
    
}

- (void)viewDidUnload {
    [self setAnnotationView:nil];
    [super viewDidUnload];
}


@end

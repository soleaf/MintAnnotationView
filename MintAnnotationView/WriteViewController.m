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
}

- (IBAction)annotateMary:(id)sender {
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:@"0" forKey:MintAnnotationInfoID];
    [info setObject:@"Mary" forKey:MintAnnotationInfoName];
    [info setObject:@"Other user Information" forKey:@"others"];
    
    [self.annotationView annotation:info];
}

- (IBAction)annotateJames:(id)sender {
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:@"1" forKey:MintAnnotationInfoID];
    [info setObject:@"James" forKey:MintAnnotationInfoName];
    [info setObject:@"Other user Information" forKey:@"others"];
    
    [self.annotationView annotation:info];
}

- (IBAction)annotateSally:(id)sender {
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:@"2" forKey:MintAnnotationInfoID];
    [info setObject:@"Sally" forKey:MintAnnotationInfoName];
    [info setObject:@"Other user Information" forKey:@"others"];
    
    [self.annotationView annotation:info];
}


#pragma mark - UITextViewDelegate (Required)

- (void)textViewDidChange:(UITextView *)textView
{
    // Checking User trying to remove MintAnnotationView's annoatation
    [self.annotationView checkTagDeleting];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // Checking User trying to edit MintAnnotationView's annoatation
    return [self.annotationView checkingEditingTag:textView andRange:range];
    
}

- (void)viewDidUnload {
    [self setAnnotationView:nil];
    [super viewDidUnload];
}


@end

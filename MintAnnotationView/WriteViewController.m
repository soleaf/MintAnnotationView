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

- (void)textViewDidChange:(UITextView *)textView
{
    // 태그가 삭제되는지 확인
    [self.annotationView checkTagDeleting];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // 태그를 편집하려하는지
    return [self.annotationView checkingEditingTag:textView andRange:range];
    
}

- (void)viewDidUnload {
    [self setAnnotationView:nil];
    [super viewDidUnload];
}


@end

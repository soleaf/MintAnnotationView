//
//  TestMintAnnotationChatView.m
//  MintAnnotationView
//
//  Created by soleaf on 14. 2. 10..
//  Copyright (c) 2014년 mintcode.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MintAnnotationChatView.h"

static NSString* const keyModelId = @"mintACV_id";

@interface TestMintAnnotationChatView : SenTestCase

@property NSMutableArray *annotationList;
@property NSAttributedString *attributedText;

@end

//@implementation TestMintAnnotationChatView
//
//- (void)setUp
//{
//    [super setUp];
//    // Put setup code here; it will be run once, before the first test case.
//}
//
//- (void)tearDown
//{
//    // Put teardown code here; it will be run once, after the last test case.
//    [super tearDown];
//}
//
//- (void)testExample
//{
//    Annotation *annotation = [[Annotation alloc] init];
//    annotation.usr_id = @"1";
//    annotation.usr_name = @"asdfsadf";
//    
//    [self addAnnotation:annotation];
//    
//    NSLog(@"self.attributedText >>>%@<<<",self.attributedText);
//    
//    STAssertTrue(1, @"");
//    
//}
//
//
//
////- (NSArray *) findTagPosition:(Annotation*)annoation
////{
////    
////}
//
//
//- (void)addAnnotation:(Annotation *)newAnnoation
//{
//    // Check aleady imported
//    for (Annotation *annotation in self.annotationList) {
//        
//        if ([annotation.usr_id isEqualToString:newAnnoation.usr_id])
//            return;
//    }
//    
//    // Add
//    [self.annotationList addObject:newAnnoation];
//    
//    // Insert Plain user name text
//    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc]
//                                             initWithString:newAnnoation.usr_name
//                                             attributes:@{keyModelId : newAnnoation.usr_id}];
//    
//    NSMutableAttributedString *spaceStringPefix = nil;
//    NSString *tempCommentWriting = self.attributedText.string;
//    
//    // display name
//    
//    // Add Space
//    if (tempCommentWriting.length > 0){
//        
//        NSString *prevString = [tempCommentWriting substringFromIndex:tempCommentWriting.length-1];
//        
//        if (![prevString isEqualToString:@"\n"])
//        {
//            spaceStringPefix = [[NSMutableAttributedString alloc] initWithString:@" "];
//        }
//    }
//    
//    NSMutableAttributedString *conts = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
//    if (spaceStringPefix)
//        [conts appendAttributedString:spaceStringPefix];
//    [conts appendAttributedString:nameString];
//    [conts appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" "]];
//    
//    
//    self.attributedText = conts;
//    
////    [self setNeedsDisplay];
//    
//    // Pass Delegate
////    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:)])
////        [self.delegate textViewDidChange:self];
//}
//
//
//@end

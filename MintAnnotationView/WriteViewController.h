//
//  WriteViewController.h
//  MintAnnotationView
//
//  Created by soleaf on 13. 8. 26..
//  Copyright (c) 2013년 mintcode.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MintAnnotationChatView.h"

@interface WriteViewController : UIViewController<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet MintAnnotationChatView *annotationView;

@end

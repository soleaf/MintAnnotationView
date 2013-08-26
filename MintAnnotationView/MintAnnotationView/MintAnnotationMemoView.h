//
//  MintAnnotationView.h
//  MintAnnotationView
//
//  Created by soleaf on 13. 8. 26..
//  Mintcode.org
//  http://www.mintcode.org/
//  Repository : https://github.com/soleaf/MintAnnotationView
//

#import <UIKit/UIKit.h>

// Annotation Information Dictionary Keys
#define MintAnnotationInfoID @"id"
#define MintAnnotationInfoName @"name"

@interface MintAnnotationMemoView : UITextView

@property UIColor *nameTagColor;
@property UIColor *nameTagLineColor;
@property NSMutableArray *annotationList;

- (NSString *)annotationWithMemo:(NSString *)memo;

@end

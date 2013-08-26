//
//  MintAnnotationView.h
//  MintAnnotationView
//
//  Created by soleaf on 13. 8. 26..
//  Mintcode.org
//  http://www.mintcode.org/
//  Repository : https://github.com/soleaf/MintAnnotationVIew
//

#import <UIKit/UIKit.h>

// Annotation Information Dictionary Keys
#define MintAnnotationInfoID @"id"
#define MintAnnotationInfoName @"name"

@interface MintAnnotationChatView : UITextView

@property UIColor *nameTagColor;
@property UIColor *nameTagLineColor;
@property NSMutableArray *annotationList;

- (void) annotation:(NSDictionary*)info;
- (void) checkTagDeleting;
- (BOOL) checkingEditingTag:(UITextView*) textView andRange:(NSRange) editingRange;

@end

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
#define MintAnnotationInfoID    @"id"
#define MintAnnotationInfoName  @"name"

@interface MintAnnotationChatView : UITextView

@property UIColor        *nameTagColor;
@property UIColor        *nameTagLineColor;
@property NSMutableArray *annotationList;


// Add new Anotation
// info should include 'MintAnnotationInfoID', 'MintAnnotationInfoName'
//              MintAnnotationInfoID   = Unique Identifier to disturb dobule inserting same info.
//              MintAnnotationInfoName = Appeared name in view.
- (void) annotation:(NSDictionary*)info;


// Should Use on textViewDelegate on viewController
/* EX)
    - (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
    {
        return [self.annotationView checkingEditingTag:textView andRange:range];
        
    }
 */
- (void) checkTagDeleting;


// Should Use on textViewDelegate on viewController
/* EX)
     - (void)textViewDidChange:(UITextView *)textView
     {
        [self.annotationView checkTagDeleting];
     }
 */
- (BOOL) checkingEditingTag:(UITextView*) textView andRange:(NSRange) editingRange;

@end

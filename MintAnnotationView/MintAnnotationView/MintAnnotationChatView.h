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
#import "MintAnnotation.h"

// Annotation Information Dictionary Keys
static NSString* const MintAnnotationInfoID = @"id";
static NSString* const MintAnnotationInfoName = @"name";

@interface MintAnnotationChatView : UITextView

@property UIColor        *nameTagColor;
@property UIColor        *nameTagLineColor;
@property NSMutableArray *annotationList;
@property UIImage        *nameTagImage;

// Add new Anotation
// info should include 'MintAnnotationInfoID', 'MintAnnotationInfoName'
//              MintAnnotationInfoID   = Unique Identifier to disturb dobule inserting same info.
//              MintAnnotationInfoName = Appeared name in view.
- (void) addAnnotation:(MintAnnotation*)annoatin;


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
- (BOOL) shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

@end

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

@interface MintAnnotationChatView : UITextView <UITextViewDelegate>

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
- (void)textViewDidChange:(UITextView *)textView;


// Should Use on textViewDelegate on viewController
/* EX)
     - (void)textViewDidChange:(UITextView *)textView
     {
        [self.annotationView checkTagDeleting];
     }
 */
- (BOOL) shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

/*
 Make string with tag information
 ex ) hi <u id="1">Sally</u> good morning.
 tagIdKey = id
 */
- (NSString*) makeStringWithTagAndTagIdKey:(NSString*)tagIdKey;

/*
 remove text and attributes and annotationList
 */
- (void) clearAll;

@end

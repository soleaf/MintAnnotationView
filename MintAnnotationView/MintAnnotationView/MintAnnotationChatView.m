//
//  MintAnnotationView.m
//  MintAnnotationView
//
//  Created by soleaf on 13. 8. 26..
//  Mintcode.org
//  http://www.mintcode.org/
//  Repository : https://github.com/soleaf/MintAnnotationView
//

#import <QuartzCore/QuartzCore.h>
#import "MintAnnotationChatView.h"

@interface MintAnnotationChatView()
{
    BOOL isModified;
    NSString *beforeStrForCheckingDeleting;
    NSMutableArray *tagViews;
}

@end

@implementation MintAnnotationChatView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeRedraw;
        tagViews = [[NSMutableArray alloc] init];
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    for (UIView *tagView in tagViews) {
        [tagView removeFromSuperview];
    }
    
    if (self.annotationList == nil) return;
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();

    UITextView *textView = self;
    
    // 1. Define search keyword
    NSString *finding = textView.text;
    
    // 2. Pos = before text pos + new pos
    NSInteger prefixPos = 0;
    
    // 3. Find and draw
    while ([finding rangeOfString:@"@"].location != NSNotFound) {
        
        // 1) Where is '@'
        NSInteger startPos = [finding rangeOfString:@"@"].location;
        
        // 2) Cut
        NSString *findingStr = [finding substringFromIndex:startPos];
    
        NSInteger endPos = [findingStr rangeOfString:@" "].location;
        
        if (endPos < 1 || endPos > findingStr.length) return;
        
        // 3) Is in annotation list.
        NSString *name = [[findingStr substringToIndex:endPos] substringFromIndex:1];
        BOOL nameInAnnoncedList = NO;
        for (NSDictionary *item in self.annotationList) {
            if ([[item objectForKey:MintAnnotationInfoName] isEqualToString:name]) {
                nameInAnnoncedList = YES;
                break;
            }
        }
        
        if (nameInAnnoncedList){
            
            // 4) Find rect
            CFRange stringRange = CFRangeMake(startPos +prefixPos, endPos);
            UITextPosition *begin = [textView positionFromPosition:textView.beginningOfDocument offset:stringRange.location];
            UITextPosition *end = [textView positionFromPosition:begin offset:stringRange.length];
            UITextRange *textRange = [textView textRangeFromPosition:begin toPosition:end];
            
            // 5) Need 2line?
            CGPoint firstLineBeginPosition = [textView caretRectForPosition:begin].origin;
            CGPoint secondLineEndPosition = [textView caretRectForPosition:end].origin;
            
            if (firstLineBeginPosition.y < secondLineEndPosition.y){
                
                // Finf pos of first line
                float secondY = firstLineBeginPosition.y;
                CFRange secondStrRange = CFRangeMake(startPos+ prefixPos, 1);
                NSInteger secondPos = startPos + prefixPos;
                NSInteger cnt = 0;
                
                while (secondY < secondLineEndPosition.y) {
                    
                    secondPos++;
                    cnt++;
                    
                    secondStrRange = CFRangeMake(secondPos, stringRange.length - cnt);
                    UITextPosition *secondBegin = [textView positionFromPosition:textView.beginningOfDocument offset:secondStrRange.location];
                    CGPoint secondPosition = [textView caretRectForPosition:secondBegin].origin;
                    secondY = secondPosition.y;
                    
                }
                
                // Calculate rect
                UITextPosition *secondBegin = [textView positionFromPosition:textView.beginningOfDocument offset:secondStrRange.location];
                UITextPosition *secondEnd = [textView positionFromPosition:secondBegin offset:secondStrRange.length];
                UITextRange *secondTextRange = [textView textRangeFromPosition:secondBegin toPosition:secondEnd];
                
                // 1st line
                [self drawTag:context Rect:[textView firstRectForRange:textRange]
                         name:[self textInRange:[textView textRangeFromPosition:textRange.start toPosition:secondBegin]]];
                
                // 2nd Line
                [self drawTag:context Rect:[textView firstRectForRange:secondTextRange]
                                    name:[self textInRange:secondTextRange]];
            }
            else{
                // Draw rect first line
                [self drawTag:context Rect:[textView firstRectForRange:textRange] name:[self textInRange:textRange]];
            }
            
        } // End if of Check is in annotation list.
        
        prefixPos = prefixPos + startPos + endPos;
        finding = [finding substringFromIndex:startPos+endPos]; // Keyword more to find
        
    }
}

- (void) drawTag: (CGContextRef) context Rect:(CGRect) rect name:(NSString*)nameText
{
    if(self.nameTagImage)
        [self drawTagImageInRect:rect name:nameText];
    else
        [self drawRectangle:context Rect:rect];
}

- (void) drawRectangle: (CGContextRef) context Rect:(CGRect) rect
{
    rect.size.width+=1;
    rect.size.height-=2;
    rect.origin.y+=1;
    
    if (_nameTagColor == nil)
        self.nameTagColor = [UIColor colorWithRed:0.98 green:1.00 blue:0.71 alpha:0.5];
    if (_nameTagLineColor == nil)
        self.nameTagLineColor = [UIColor colorWithRed:1.00 green:0.81 blue:0.35 alpha:0.6];
    
    CGContextSetFillColorWithColor(context, _nameTagColor.CGColor);
    CGContextSetStrokeColorWithColor(context, _nameTagLineColor.CGColor);
    
    // Draw line
    CGContextAddRect(context, rect);
    CGContextStrokePath(context);
    
    // Fill
    CGContextFillRect(context, rect);
    CGContextStrokeRectWithWidth(context, rect, 0.5);
}

- (void) drawTagImageInRect:(CGRect) rect name:(NSString*)nameText
{
    self.nameTagColor = self.nameTagColor;
    
    UIImageView *tagImage = [[UIImageView alloc] initWithFrame:rect];
    tagImage.image = self.nameTagImage;
    [self addSubview:tagImage];
    
    UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(rect.origin.x+2, rect.origin.y+2, rect.size.width-4, rect.size.height-4)];
    tagLabel.textColor = _nameTagColor;
    tagLabel.text = nameText;
    tagLabel.backgroundColor = [UIColor clearColor];
    tagLabel.font = [UIFont systemFontOfSize:self.font.pointSize-2];
    tagLabel.textAlignment = NSTextAlignmentCenter;
    tagLabel.minimumScaleFactor = 1.;
    [self addSubview:tagLabel];
    
    [tagViews addObject:tagImage];
    [tagViews addObject:tagLabel];
}

- (void)annotation:(NSDictionary *)info
{

    // Check Is Already Imported
    BOOL isAlreadyAdded = NO;
    for (NSDictionary *item in self.annotationList) {
        
        if ([[item objectForKey:MintAnnotationInfoID]isEqualToString:[info objectForKey:MintAnnotationInfoID]])
            isAlreadyAdded = YES;
    }
    
    if (!isAlreadyAdded){
        
        if (self.annotationList == nil) self.annotationList = [[NSMutableArray alloc] init];
        
        NSString *tempCommentWriting = self.text;
        
        // display name
        if (tempCommentWriting.length == 0){
            tempCommentWriting = [NSString stringWithFormat:@"@%@ ", [info objectForKey:MintAnnotationInfoName]];
        }
        else{
            
            NSString *prevString = [tempCommentWriting substringFromIndex:tempCommentWriting.length-1];
            
            // This is first word after new line.
            if ([prevString isEqualToString:@"\n"])
                tempCommentWriting = [NSString stringWithFormat:@"%@@%@ ",
                                      tempCommentWriting, [info objectForKey:MintAnnotationInfoName]];
            else
                tempCommentWriting = [NSString stringWithFormat:@"%@ @%@ ",
                                      tempCommentWriting, [info objectForKey:MintAnnotationInfoName]];
            
        }
        
        self.text = tempCommentWriting;
    }
    
    // Add info to annotationList
    [self.annotationList addObject:info];
    
    [self setNeedsDisplay];
    
    // Pass Delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:)])
        [self.delegate textViewDidChange:self];

}


- (void) checkTagDeleting
{
    
    if (isModified){
        isModified = NO;
        return;
    }
    
    UITextView *textView = self;
    
    // 0. Check deleting
    if (beforeStrForCheckingDeleting.length > textView.text.length){
        
        // 1. Is deleted Char on tag ?
        
        // 1) Diff
        NSInteger modifiedPos = [self findChangedPoint:beforeStrForCheckingDeleting andModified:textView.text];
        
        // 2) Is in AnnotationList Deleted char's?
        
        // Where is pos of '@'
        
        // (1) Define keyword to find
        NSString *finding = beforeStrForCheckingDeleting;
        
        // (2) Before Keyword Pos + New Pos
        NSInteger prefixPos = 0;
        
        while ([finding rangeOfString:@"@"].location != NSNotFound) {
            
            // Pos of '@'
            NSInteger startPos = [finding rangeOfString:@"@"].location;
            
            // Cut
            NSString *findingStr = [finding substringFromIndex:startPos];

            NSInteger endPos = [findingStr rangeOfString:@" "].location;
            
            if (endPos < 1 || endPos > findingStr.length) return;
            
            // Find rect
            NSInteger tagRangeBegin = startPos + prefixPos;
            NSInteger tagRangeEnd = tagRangeBegin + endPos;
            
            // Is in AnnounceList a rect
            if (tagRangeBegin <= modifiedPos && modifiedPos <= tagRangeEnd){
                
                // Disturb Recall (infinite loop)
                isModified = YES;
                
                // Remove all chars of annotation tag
                if (tagRangeEnd >= textView.text.length) tagRangeEnd = textView.text.length;
                
                // Remove it for annotation list
                NSString *name = [[findingStr substringToIndex:endPos] substringFromIndex:1];
                BOOL isDeleted = NO;
                for (NSInteger i = 0; i < self.annotationList.count; i++) {
                    
                    NSDictionary *item = [self.annotationList objectAtIndex:i];
                    if ([[item objectForKey:MintAnnotationInfoName] isEqualToString:name]) {
                        [self.annotationList removeObjectAtIndex:i];
                        isDeleted = YES;
                        break;
                    }
                    
                }
                
                if (isDeleted){
                    
                    textView.text =  [NSString stringWithFormat:@"%@%@",[textView.text substringToIndex:tagRangeBegin], [textView.text substringFromIndex:tagRangeEnd]];
                    beforeStrForCheckingDeleting = textView.text;
                    [textView setNeedsDisplay];
                    return;
                    
                }
                
                
                
            }
            
            prefixPos = prefixPos + startPos + endPos;
            finding = [finding substringFromIndex:startPos+endPos]; // More searching keyword
            
        }
        
       
    }

    [self setNeedsDisplay];
    beforeStrForCheckingDeleting = textView.text;
}

- (BOOL) checkingEditingTag:(UITextView*) textView andRange:(NSRange) editingRange
{
    // 0. Check deleting
    
    // 1. Is deleted Char on tag?
    
    // (1) Define Keyword
    NSString *finding = beforeStrForCheckingDeleting;
    
    // (2) Before searched pos + new pos
    NSInteger prefixPos = 0;
    
    while ([finding rangeOfString:@"@"].location != NSNotFound) {
        
        // Check pos of '@'
        NSInteger startPos = [finding rangeOfString:@"@"].location;
        
        // Cut
        NSString *findingStr = [finding substringFromIndex:startPos];
        
        NSInteger endPos = [findingStr rangeOfString:@" "].location;
        
        if (endPos < 1 || endPos > findingStr.length) return YES; // Permit edit
        
        // Find rect
        NSInteger tagRangeBegin = startPos + prefixPos;
        NSInteger tagRangeEnd = tagRangeBegin + endPos;
        
        // Is in AnnounceList a rect
        if (tagRangeBegin < editingRange.location && editingRange.location + editingRange.length -1 < tagRangeEnd -1){
            
            NSString *name = [[findingStr substringToIndex:endPos] substringFromIndex:1];
            BOOL nameInAnnoncedList = NO;
            for (NSDictionary *item in self.annotationList) {
                
                if ([[item objectForKey:MintAnnotationInfoName] isEqualToString:name]) {
                    nameInAnnoncedList = YES;
                    break;
                }
                
            }
            
            return  nameInAnnoncedList ? NO : YES;
        }
        
        prefixPos = prefixPos + startPos + endPos;
        finding = [finding substringFromIndex:startPos+endPos]; // More searching keyword
        
    }
    
    return YES;
    
}


- (NSInteger) findChangedPoint: (NSString*)origin andModified :(NSString*) comparison
{
    // Return Region pos of tow text
    
    NSInteger point = 0;
    
    for (point = 0; point < origin.length; point++) {
        
        if (comparison.length <= point || origin.length <= point) break;
        
        // Occur a diff
        if (![[origin substringToIndex:point] isEqualToString:[comparison substringToIndex:point]]) break;
        
    }
    
    return point;
}


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return NO;
}
@end

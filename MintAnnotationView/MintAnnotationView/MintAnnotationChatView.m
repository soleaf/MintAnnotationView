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
}

@end

@implementation MintAnnotationChatView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeRedraw;
        
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
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
            
            // 5) Find rect
            CFRange stringRange = CFRangeMake(startPos +prefixPos, endPos);
            UITextPosition *begin = [textView positionFromPosition:textView.beginningOfDocument offset:stringRange.location];
            UITextPosition *end = [textView positionFromPosition:begin offset:stringRange.length];
            UITextRange *textRange = [textView textRangeFromPosition:begin toPosition:end];
            
            // 6) Draw rect
            [self drawRectangle:context Rect:[textView firstRectForRange:textRange]];
            
            // 7) Need 2line?
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
                
                // Redraw
                [self drawRectangle:context Rect:[textView firstRectForRange:secondTextRange]];
                
            }
            
        } // End if of Check is in annotation list.
        
        prefixPos = prefixPos + startPos + endPos;
        finding = [finding substringFromIndex:startPos+endPos]; // Keyword more to find
        
    }
}

- (void) drawRectangle: (CGContextRef) context Rect:(CGRect) rect
{
    //    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor)
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
        if (tempCommentWriting == nil)
            tempCommentWriting = [NSString stringWithFormat:@"@%@ ", [info objectForKey:MintAnnotationInfoName]];
        else
            tempCommentWriting = [NSString stringWithFormat:@"%@ @%@ ", tempCommentWriting, [info objectForKey:MintAnnotationInfoName]];
        
        self.text = tempCommentWriting;
    }
    
    // Add info to annotationList
    [self.annotationList addObject:info];
    
    [self setNeedsDisplay];

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
        
        if (endPos < 1 || endPos > findingStr.length) return YES; // 편집허용
        
        // 사각형 찾기
        NSInteger tagRangeBegin = startPos + prefixPos;
        NSInteger tagRangeEnd = tagRangeBegin + endPos;
        
        // 언급 범위에 변경된 좌표가 포함되어있는지 확인
        if (tagRangeBegin < editingRange.location && editingRange.location + editingRange.length -1 < tagRangeEnd -1){
            
            NSString *name = [[findingStr substringToIndex:endPos] substringFromIndex:1];
            BOOL nameInAnnoncedList = NO;
            for (NSDictionary *item in self.annotationList) {
                
                if ([[item objectForKey:MintAnnotationInfoName] isEqualToString:name]) {
                    nameInAnnoncedList = YES;
                    break;
                }
                
            }
            
            // 태그가 수정됨
            return  nameInAnnoncedList ? NO : YES;
        }
        
        prefixPos = prefixPos + startPos + endPos;
        finding = [finding substringFromIndex:startPos+endPos]; // 더찾을 텍스트
        
    }
    
    return YES;
    
}



- (NSInteger) findChangedPoint: (NSString*)origin andModified :(NSString*) comparison
{
    // 두 텍스트 사이의 차이점이 있는 좌표를 반환(0부터 탐색)
    
    NSInteger point = 0;
    
    for (point = 0; point < origin.length; point++) {
        
        // 비교대상의 길이가 검사포인트보다 작으면: 더이상 검사할게 없음 -> 완료
        if (comparison.length <= point || origin.length <= point) break;
        
        // 검사포인트에서 차이가 발견 -> 완료
        if (![[origin substringToIndex:point] isEqualToString:[comparison substringToIndex:point]]) break;
        
    }
    
    return point;
}
@end

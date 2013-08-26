//
//  MintAnnotationView.m
//  MintAnnotationView
//
//  Created by soleaf on 13. 8. 26..
//  Mintcode.org
//  http://www.mintcode.org/
//  Repository : https://github.com/soleaf/MintAnnotationVIew
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
    
    // @의 좌표를 알아내야해
    UITextView *textView = self;
    
    // 1. 검색 텍스트 지정
    NSString *finding = textView.text;
    
    // 2. 여러번 찾을 때 스타일을 지정할 좌표 = 이전텍스트길이(prefixPos) + 찾은 좌표
    NSInteger prefixPos = 0;
    
    // 3. 찾아서 스타일링
    while ([finding rangeOfString:@"@"].location != NSNotFound) {
        
        // 1) @좌표의 텍스트 확인
        NSInteger startPos = [finding rangeOfString:@"@"].location;
        
        // 2) @좌표부터 끝까지 잘라내기
        NSString *findingStr = [finding substringFromIndex:startPos];
        
        // 3) 잘라낸 텍스트에 공백을 찾음
        NSInteger endPos = [findingStr rangeOfString:@" "].location;
        
        if (endPos < 1 || endPos > findingStr.length) return;
        
        // 3.1) 언급리스트에 있는지 확인
        NSString *name = [[findingStr substringToIndex:endPos] substringFromIndex:1];
        BOOL nameInAnnoncedList = NO;
        for (NSDictionary *item in self.annotationList) {
            if ([[item objectForKey:MintAnnotationInfoName] isEqualToString:name]) {
                nameInAnnoncedList = YES;
                break;
            }
        }
        
        if (nameInAnnoncedList){
            
            // 5) 사각형 찾기
            CFRange stringRange = CFRangeMake(startPos +prefixPos, endPos);
            UITextPosition *begin = [textView positionFromPosition:textView.beginningOfDocument offset:stringRange.location];
            UITextPosition *end = [textView positionFromPosition:begin offset:stringRange.length];
            UITextRange *textRange = [textView textRangeFromPosition:begin toPosition:end];
            
            // 6) 사각형그리기
            [self drawRectangle:context Rect:[textView firstRectForRange:textRange]];
            
            // 7) 두줄인지
            CGPoint firstLineBeginPosition = [textView caretRectForPosition:begin].origin;
            CGPoint secondLineEndPosition = [textView caretRectForPosition:end].origin;
            NSLog(@"%f -> %f",firstLineBeginPosition.y, secondLineEndPosition.y);
            
            if (firstLineBeginPosition.y < secondLineEndPosition.y){
                
                // 두번째줄의 첫번째 위치를 찾아냄
                float secondY = firstLineBeginPosition.y;
                CFRange secondStrRange = CFRangeMake(startPos+ prefixPos, 1); // 첫번째줄 첫글자부터 이동해서 찾아감
                NSInteger secondPos = startPos + prefixPos;
                NSInteger cnt = 0;
                
                while (secondY < secondLineEndPosition.y) {
                    
                    secondPos++;
                    cnt++;
                    
                    secondStrRange = CFRangeMake(secondPos, stringRange.length - cnt);
                    UITextPosition *secondBegin = [textView positionFromPosition:textView.beginningOfDocument offset:secondStrRange.location];
                    CGPoint secondPosition = [textView caretRectForPosition:secondBegin].origin;
                    secondY = secondPosition.y;
                    
                    NSLog(@"secondPos: %d secondPosition: %f  ~ endPos :%ld", secondPos, secondY, (long)endPos);
                    
                }
                
                NSLog(@"두줄");
                
                // 사각형 계산
                UITextPosition *secondBegin = [textView positionFromPosition:textView.beginningOfDocument offset:secondStrRange.location];
                UITextPosition *secondEnd = [textView positionFromPosition:secondBegin offset:secondStrRange.length];
                UITextRange *secondTextRange = [textView textRangeFromPosition:secondBegin toPosition:secondEnd];
                
                // 다시그리기
                [self drawRectangle:context Rect:[textView firstRectForRange:secondTextRange]];
                
            }
            
        } // 언급목록에 포함된 이름인지 확인하는 if문 끝
        
        prefixPos = prefixPos + startPos + endPos;
        finding = [finding substringFromIndex:startPos+endPos]; // 더찾을 텍스트
        
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
    
    // 사각형 선그리기
    CGContextAddRect(context, rect);
    CGContextStrokePath(context);
    
    // 사각형 채우기
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
    
    // 무한루프 방지
    if (isModified){
        isModified = NO;
        return;
    }
    
    UITextView *textView = self;
    
    // 0. 삭제중인지 확인
    if (beforeStrForCheckingDeleting.length > textView.text.length){
        
        // 1. 태그의 일부가 삭제됬는지 확인: 글쎄..... 어케알아... -_-...
        
        // 1) 이전꺼와 현재꺼가 다른 좌표를 찾음
        NSInteger modifiedPos = [self findChangedPoint:beforeStrForCheckingDeleting andModified:textView.text];
        NSLog(@"바뀐곳: %d", modifiedPos);
        
        // 2) 태그목록에서 삭제된 좌표가 해당되었는지
        
        // @의 좌표를 알아내야해
        
        // (1) 검색 텍스트 지정
        NSString *finding = beforeStrForCheckingDeleting;
        
        // (2) 여러번 찾을 때 스타일을 지정할 좌표 = 이전텍스트길이(prefixPos) + 찾은 좌표
        NSInteger prefixPos = 0;
        
        while ([finding rangeOfString:@"@"].location != NSNotFound) {
            
            // @좌표의 텍스트 확인
            NSInteger startPos = [finding rangeOfString:@"@"].location;
            
            // @좌표부터 끝까지 잘라내기
            NSString *findingStr = [finding substringFromIndex:startPos];
            
            // 잘라낸 텍스트에 공백을 찾음
            NSInteger endPos = [findingStr rangeOfString:@" "].location;
            
            if (endPos < 1 || endPos > findingStr.length) return;
            
            // 사각형 찾기
            NSInteger tagRangeBegin = startPos + prefixPos;
            NSInteger tagRangeEnd = tagRangeBegin + endPos;
            
            // 언급 범위에 변경된 좌표가 포함되어있는지 확인
            NSLog(@"tagRangeBegin %d modifiedPos %d tagRangeEnd %d",tagRangeBegin, modifiedPos, tagRangeEnd);
            if (tagRangeBegin <= modifiedPos && modifiedPos <= tagRangeEnd){
                
                // 태그가 삭제됨
                
                // 플래그로 무한루프 방지
                isModified = YES;
                
                // 해당 캐그 통채로 증발
                if (tagRangeEnd >= textView.text.length) tagRangeEnd = textView.text.length;
                
                // 태그 목록에서 제거
                NSString *name = [[findingStr substringToIndex:endPos] substringFromIndex:1];
                BOOL isDeleted = NO;
                for (NSInteger i = 0; i < self.annotationList.count; i++) {
                    
                    NSDictionary *item = [self.annotationList objectAtIndex:i];
                    if ([[item objectForKey:MintAnnotationInfoName] isEqualToString:name]) {
                        NSLog(@"태그삭제 :%@", [item objectForKey:MintAnnotationInfoName]);
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
            finding = [finding substringFromIndex:startPos+endPos]; // 더찾을 텍스트
            
        }
        
       
    }

    [self setNeedsDisplay];
    beforeStrForCheckingDeleting = textView.text;
}

- (BOOL) checkingEditingTag:(UITextView*) textView andRange:(NSRange) editingRange
{
    // 0. 삭제중인지 확인
    
    // 1. 태그의 일부가 삭제됬는지 확인: 글쎄..... 어케알아... -_-...
    
    // @의 좌표를 알아내야해
    
    // (1) 검색 텍스트 지정
    NSString *finding = beforeStrForCheckingDeleting;
    
    // (2) 여러번 찾을 때 스타일을 지정할 좌표 = 이전텍스트길이(prefixPos) + 찾은 좌표
    NSInteger prefixPos = 0;
    
    while ([finding rangeOfString:@"@"].location != NSNotFound) {
        
        // @좌표의 텍스트 확인
        NSInteger startPos = [finding rangeOfString:@"@"].location;
        
        // @좌표부터 끝까지 잘라내기
        NSString *findingStr = [finding substringFromIndex:startPos];
        
        // 잘라낸 텍스트에 공백을 찾음
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
            NSLog(@"태그수정");
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

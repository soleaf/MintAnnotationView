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

static NSString* const keyModelId = @"mintACV_id";

@interface MintAnnotationChatView()
{
    BOOL isModified;
    NSMutableArray *tagViews;
    NSString* beforeText;
}

@end

enum editType {
    editTypeInserting = 1,
    editTypeDeleting = 2,
    editTypeModifying = 3
};
typedef NSInteger EditType;

@implementation MintAnnotationChatView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeRedraw;
        self.annotationList = [[NSMutableArray alloc] init];
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    [super drawRect:rect];
    
    for (UIView *tagView in tagViews) {
        [tagView removeFromSuperview];
    }
    
    if (self.annotationList == nil || self.attributedText.length  < 1) return;
    
    for (MintAnnotation *annoation in self.annotationList) {
        
        [self calculatingTagRectAndDraw:annoation.range];
        
    }
    
}

- (void) calculatingTagRectAndDraw:(NSRange) annoationStringRange
{
    /*
     Caclulating Rect and Draw
     */
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UITextView *textView = self;
    
    // 4) Find rect
    NSRange stringRange = annoationStringRange;
    UITextPosition *begin = [textView positionFromPosition:textView.beginningOfDocument offset:stringRange.location];
    UITextPosition *end = [textView positionFromPosition:begin offset:stringRange.length];
    UITextRange *textRange = [textView textRangeFromPosition:begin toPosition:end];
    
    // 5) Need 2line?
    CGPoint firstCharPosition = [textView caretRectForPosition:begin].origin;
    CGPoint lastCharPosition = [textView caretRectForPosition:end].origin;
    
    if (firstCharPosition.y < lastCharPosition.y){
        
        // Finf pos of first line
        float secondY = firstCharPosition.y;
        CFRange secondStrRange = CFRangeMake(stringRange.location, 1); // first time is just init, not have mean of value
        NSInteger secondPos = stringRange.location;
        NSInteger cnt = 0;
        
        while (secondY < lastCharPosition.y) {
            
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
}



#pragma mark - Draw Tag graphics

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
    
    UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tagButton.frame = CGRectMake(rect.origin.x,
                                 rect.origin.y+1,
                                 rect.size.width,
                                 rect.size.height);
    
    [tagButton setBackgroundImage:self.nameTagImage forState:UIControlStateNormal];
    [tagButton setTitle:nameText forState:UIControlStateNormal];
    [tagButton setTitleColor:self.nameTagColor forState:UIControlStateNormal];
    tagButton.titleLabel.font = [UIFont systemFontOfSize:self.font.pointSize-4];
    
    if (!tagViews)
        tagViews = [[NSMutableArray alloc] init];
    
    [tagViews addObject:tagButton];
    [self addSubview:tagButton];
    
    
    //    UIImageView *tagImage = [[UIImageView alloc]
    //                             tagImage.image = self.nameTagImage;
    //    [self addSubview:tagImage];
    //
    //    UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(rect.origin.x+2, rect.origin.y+2, rect.size.width-4, rect.size.height-4)];
    //    tagLabel.textColor = _nameTagColor;
    //    tagLabel.text = nameText;
    //    tagLabel.backgroundColor = [UIColor clearColor];
    //    tagLabel.font = [UIFont systemFontOfSize:self.font.pointSize-4];
    //    tagLabel.textAlignment = NSTextAlignmentCenter;
    //    tagLabel.minimumScaleFactor = .2;
    //    [self addSubview:tagLabel];
    
    //    if (!tagViews)
    //        tagViews = [[NSMutableArray alloc] init];
    
    //    [tagViews addObject:tagImage];
    //    [tagViews addObject:tagLabel];
}


#pragma mark - Modeling

// --- NEW ---
- (void)addAnnotation:(MintAnnotation *)newAnnoation
{

    // Check aleady imported
    for (MintAnnotation *annotation in self.annotationList) {
        
        if ([annotation.usr_id isEqualToString:newAnnoation.usr_id])
        {
            NSLog(@"MintAnnoationChatView >> addAnoation >> id'%@'is aleady in", newAnnoation.usr_id);
            return;
        }
    }
    
    // Add
    if (!self.annotationList) self.annotationList = [[NSMutableArray alloc] init];
    [self.annotationList addObject:newAnnoation];
    
    // Insert Plain user name text
//    
//    NSMutableAttributedString *spaceStringPefix = nil;
//    NSString *tempCommentWriting = self.text;
//    
    NSInteger cursor = self.selectedRange.location;
    if (cursor == NSNotFound) cursor = self.text.length;
    newAnnoation.range = NSMakeRange(cursor+1, newAnnoation.usr_name.length);
    
    NSLog(@"newAnnoation.range:%d,%d",newAnnoation.range.location, newAnnoation.range.length);
    self.text = [NSString stringWithFormat:@"%@ %@",self.text, newAnnoation.usr_name];
    // display name
    
    // Add Last
//    NSLog(@"self.attributedText.string.length:%d",self.attributedText.string.length);
//    if (cursor >= self.attributedText.string.length-1)
//    {
//        // Add Space
//        if (tempCommentWriting.length > 0){
//            
//            NSString *prevString = [tempCommentWriting substringFromIndex:tempCommentWriting.length-1];
//            
//            if (![prevString isEqualToString:@"\n"])
//            {
//                spaceStringPefix = [[NSMutableAttributedString alloc] initWithString:@" " attributes:[self defaultAttributedString]];
//            }
//        }
//        
//        NSMutableAttributedString *conts = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
//        if (spaceStringPefix)
//            [conts appendAttributedString:spaceStringPefix];
//        [conts appendAttributedString:nameString];
//        NSMutableAttributedString *afterBlank = [[NSMutableAttributedString alloc] initWithString:@" "
//                                                                                       attributes:[self defaultAttributedString]];
//        [conts appendAttributedString:afterBlank];
//        
//        NSLog(@"conts:%@",conts);
//        
//        self.attributedText = conts;
//        NSLog(@"\n\nself.attributedText:%@",self.attributedText);
//        
//    }
//    // Insert in text
//    else
//    {
//        self.attributedText = [self attributedStringInsertString:nameString at:cursor];
//    }
    
    
    [self setNeedsDisplay];
    
    // Pass Delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:)])
        [self.delegate textViewDidChange:self];
}

- (NSRange) findTagPosition:(MintAnnotation*)annoation
{
    
    __block NSRange stringRange = NSMakeRange(0, 0);
    [self.attributedText enumerateAttribute:keyModelId inRange:NSMakeRange(0, self.attributedText.length-1)
                                    options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
                                        
                                        if ([value isEqualToString:annoation.usr_id])
                                        {
                                            stringRange = range;
                                            //                                            stringRange = CFRangeMake(range.location, range.location + range.length);
                                        }
                                        
                                    }];
    
    return stringRange;
    
}

- (MintAnnotation *) annotationForId:(NSString*)usr_id
{
    for (MintAnnotation *annotation in self.annotationList) {
        
        if ([annotation.usr_id isEqualToString:usr_id])
            return annotation;
    }
    
    return nil;
}


- (NSString *)setTextWithTageedString:(NSString *)memo
{
    
    
    NSMutableAttributedString *parsingMemo = [[NSMutableAttributedString alloc] initWithString:memo];
    [parsingMemo setAttributes:[self defaultAttributedString] range:NSMakeRange(0, parsingMemo.length)];
    
    NSLog(@"memo:%@",parsingMemo);
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"<u uid=[^>]*>[^>]*<\\/u>"
                                  options:0
                                  error:&error];
    
    if (error){
        NSLog(@"error:%@",error.description);
        return nil;
    }
    
    [regex enumerateMatchesInString:parsingMemo.string options:0 range:NSMakeRange(0, [parsingMemo length])
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                             
                             // detect
                             // <u uid=?>?</u>
                             NSRange range = [match rangeAtIndex:0];
                             NSString *insideString = [parsingMemo.string substringWithRange:range];
                             
                             // Name
                             NSRegularExpression *regexUsrName = [NSRegularExpression
                                                                  regularExpressionWithPattern:@">[가-힣a-zA-Z0-9]*<"
                                                                  options:0
                                                                  error:nil];
                             NSRange usrNameRange = [regexUsrName rangeOfFirstMatchInString:insideString
                                                                                    options:0
                                                                                      range:NSMakeRange(0, insideString.length)];
                             
                             if (usrNameRange.location != NSNotFound)
                             {
                                 NSString *userName = [insideString substringWithRange:usrNameRange];
                                 userName = [userName stringByReplacingOccurrencesOfString:@">" withString:@""];
                                 userName = [userName stringByReplacingOccurrencesOfString:@"<" withString:@""];
                                 NSLog(@"userName:%@",userName);
                                 
                                 // ID
                                 NSRegularExpression *regexUsrID = [NSRegularExpression
                                                                    regularExpressionWithPattern:@"uid=[^>]*"
                                                                    options:0
                                                                    error:nil];
                                 NSRange usrIDRange = [regexUsrID rangeOfFirstMatchInString:insideString
                                                                                    options:0
                                                                                      range:NSMakeRange(0, insideString.length)];
                                 NSString *userID = [insideString substringWithRange:usrIDRange];
                                 userID = [userID stringByReplacingOccurrencesOfString:@"uid=" withString:@""];
                                 userID = [userID stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                                 NSLog(@"userID:%@",userID);
                                 
                                 if (userID && userName)
                                 {
                                     MintAnnotation *annotation = [[MintAnnotation alloc] init];
                                     annotation.usr_id = userID;
                                     annotation.usr_name = userName;
                                     
                                     if (!self.annotationList) self.annotationList = [[NSMutableArray alloc] init];
                                     
                                     [self.annotationList addObject:annotation];
                                     
                                     NSRange userNameStringRange = NSMakeRange(range.location + usrNameRange.location+1, usrNameRange.length-2);
                                     NSLog(@"nameRange:%d,%d",userNameStringRange.location,userNameStringRange.length);
                                     [parsingMemo addAttribute:keyModelId value:userID range:userNameStringRange];
                                 }
                                 
                                 
                             }
                             
                         }];
    
    
    NSRange r;
    
    while ((r = [[parsingMemo mutableString] rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        
        [[parsingMemo mutableString] replaceCharactersInRange:r withString:@""];
    }
    
    self.attributedText = parsingMemo;
    [self setNeedsDisplay];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:)])
        [self.delegate textViewDidChange:self];
    
    
    return self.attributedText.string;
}



#pragma mark - UITextviewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    beforeText = self.text;
    [self setNeedsDisplay];
    
    // length = 0, but attributed have id
    if (self.attributedText.string.length == 0)
    {
        [self clearAllAttributedStrings];
    }
    
    return;
    
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)editingRange replacementText:(NSString *)text
{
    NSLog(@"editingRange:%d,%d, text:%@",editingRange.location, editingRange.length, text);
    
    // Dissable to edit seleted text
    if (editingRange.length > 1) return NO;
    
    // Checking EditingType
    NSInteger factorRLen = editingRange.length * 2;
    NSInteger factorTLen = (text.length > 0 ? 1 : 0);
    EditType editing = factorRLen + factorTLen;
    
    // Insert
    if (editing == editTypeInserting)
    {
        

//        NSLog(@"... i range %d,%d",editingRange.location, editingRange.length);
        NSRange range = NSMakeRange(editingRange.location -1, self.text.length - editingRange.location+1);
        
        // tyring to insert in Tag
        NSArray *annotationInList = [self annoationsInRange:NSMakeRange(editingRange.location, 1) allInclude:YES];
        if (annotationInList.count > 0 && range.location != self.text.length-1)
            return NO;
        else
        {
            
//            if (editingRange.location > 0)
//            {
//                NSString *fowardChar = [self.text substringWithRange:NSMakeRange(editingRange.location-=1, 1)];
//                BOOL isfowardNotCompletedHangul = [fowardChar rangeOfString:@"[가-핳]" options:  NSRegularExpressionSearch].location == NSNotFound;
//                BOOL isInsertingJaeum = [text rangeOfString:@"[ㅏ-ㅣ]" options:  NSRegularExpressionSearch].location != NSNotFound;
//                
//                // 미완성 한글
//                if (!(isfowardNotCompletedHangul && isInsertingJaeum))
//                    [self updateAnnoationInRange:range location:text.length enabledAutoFix:NO];
//            }
//            NSUInteger newLength = [self.text length] + [text length] - editingRange.length;
//            NSLog(@"before %d",self.text.length);
//            NSLog(@"new    %d",newLength);
//            
//            if (self.text.length < newLength)
//            {
                // 바로 전 문자가 미완성이고, 이번문가 모음이면 업데이트 넘기기
            [self updateAnnoationInRange:range location:text.length enabledAutoFix:YES];
            
//            }
//            else
//            {
//            }
            
                
            
            
            
        }
    }
    
    // Delete
    else if (editing == editTypeDeleting)
    {
        NSLog(@"... d range %d,%d",editingRange.location, editingRange.length);
        NSRange range = NSMakeRange(editingRange.location, self.text.length - editingRange.location);
    
        // tyring to delete Tag
        NSArray *annotationInList = [self annoationsInRange:NSMakeRange(editingRange.location-1, 1) allInclude:NO];
        if (annotationInList.count > 0)
        {
            // Remove tag's all text and annoation
            [self removeAnnoationAndTextInView:[annotationInList objectAtIndex:0]];
        }
        else
        {
            [self updateAnnoationInRange:range location:-1 enabledAutoFix:YES];
        }
        
    }
    
    //Modifying
    else if (editing == editTypeModifying)
    {
        // tyring to modify Tag
    }
    
    return YES;
    
}

- (void) updateAnnoationInRange:(NSRange)editingRange location:(NSInteger)delta enabledAutoFix:(BOOL)autoFix
{
    
//    NSLog(@"editingRange:%d,%d, deleta:%d",editingRange.location, editingRange.length, delta);
    NSArray *annotationsInRange = [self annoationsInRange:editingRange allInclude:YES];
    
    for (MintAnnotation *annoation in annotationsInRange) {
        
        NSRange annRange = annoation.range;
        annRange.location += delta;
        annoation.range = annRange;
        
        if (autoFix)
        {
            // 해당 range와 일치 하지 않을 경우 +1/-1까지 범위를 지정해서 픽스
            if (![[self.text substringWithRange:annoation.range] isEqualToString:annoation.usr_name])
            {
                
                // -1
                if (annoation.range.location > 0)
                {
                    if ([[self.text substringWithRange:NSMakeRange(annoation.range.location-1, annoation.range.length)]
                         isEqualToString:annoation.usr_name])
                    {
                        NSLog(@"-1 픽싱");
                        continue;
                    }

                }
                // +1
                if (annoation.range.location + annoation.range.length < self.text.length)
                {
                    if ([[self.text substringWithRange:NSMakeRange(annoation.range.location+1, annoation.range.length)]
                         isEqualToString:annoation.usr_name])
                    {
                        NSLog(@"+1 픽싱");
                        continue;
                    }
                }
                
            }
            
            
        }
        
//        NSLog(@"annRange:%d,%d",annRange.location,annRange.length);
        
    }
    
    [self setNeedsDisplay];
}

- (void) removeAnnoationAndTextInView:(MintAnnotation*)annoation
{
    NSLog(@"deleting---");
    
    self.text = [self stringWithCutOutOfRange:annoation.range];
    [self.annotationList removeObject:annoation];
    [self setNeedsDisplay];
}


#pragma mark - Search Model
- (BOOL) isAnnoation:(MintAnnotation*)annotaion InRange:(NSRange)range allInclude:(BOOL)allInclude
{
    
    NSRange annRange = annotaion.range;
    NSInteger annBegin = annRange.location;
    NSInteger annEnd = annRange.location + annRange.length;
    
//    NSLog(@"range,%d,%d - annRange,%d,%d",range.location, range.length, annRange.location,annRange.length);
    
    NSInteger rBegin = range.location;
    NSInteger rEnd = range.location + range.length;
    
    if (allInclude)
        return (rBegin <= annBegin && rEnd >= annEnd);
    else
        return ((rBegin <= annBegin && rEnd >= annBegin) ||
                (rBegin >= annBegin && rBegin <= annEnd));
}

- (NSArray *) annoationsInRange:(NSRange) range allInclude:(BOOL)allInclude
{
//    NSLog(@"in range:%d,%d",range.location, range.length);
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (MintAnnotation *annoation in self.annotationList) {
        
        if ([self isAnnoation:annoation InRange:range allInclude:allInclude])
        {
            [list addObject:annoation];
        }
    }
    
    return list;
}

#pragma mark - NSStrings
- (NSString *) stringWithCutOutOfRange:(NSRange)cuttingRange
{
    
    NSLog(@"cuttingRange:%d,%d[%@]",cuttingRange.location,cuttingRange.length, self.text);
    NSMutableString *string = [NSMutableString stringWithString:self.text];
    [string replaceCharactersInRange:cuttingRange withString:@""];
    
    return string;
}

#pragma mark - AttributedStrings
- (NSAttributedString *) attributedStringWithCutOutOfRange:(NSRange)cuttingRange
{
    /*
     Cut out string of range on full string
     to get head + tail without middle
     */
    
    // Cutting Heads
    NSAttributedString *head = nil;
    if (cuttingRange.location > 0 && cuttingRange.length > 0)
        head = [self.attributedText attributedSubstringFromRange:NSMakeRange(0, cuttingRange.location-1)];
    else
        head = [[NSMutableAttributedString alloc] initWithString:@"" attributes:[self defaultAttributedString]];
    
    
    // Cutting Tail
    
    NSAttributedString *tail = nil;
    if (cuttingRange.location + cuttingRange.length <= self.attributedText.string.length)
        tail = [self.attributedText attributedSubstringFromRange:NSMakeRange(cuttingRange.location + cuttingRange.length,
                                                                             self.attributedText.length - 1 - cuttingRange.location - cuttingRange.length)];
    
    NSMutableAttributedString *conts = [[NSMutableAttributedString alloc] initWithString:@"" attributes:[self defaultAttributedString]];
    if (head)
        [conts appendAttributedString:head];
    if (tail)
        [conts appendAttributedString:tail];
    
    return conts;
}

- (NSAttributedString *) attributedStringInsertString:(NSAttributedString*)insertingStr at:(NSInteger)position
{
    /*
     Insert str within text at position
     with blank
     -> head + blank + insertingStr + blank + tail
     */
    
    // Cutting Heads
    NSAttributedString *head = nil;
    if (position > 0 && self.attributedText.string.length > 0)
        head = [self.attributedText attributedSubstringFromRange:NSMakeRange(0, position)];
    else
        head = [[NSMutableAttributedString alloc] initWithString:@"" attributes:[self defaultAttributedString]];
    
    
    // Cutting Tail
    NSAttributedString *tail = nil;
    if (position + 1 < self.attributedText.string.length)
        tail = [self.attributedText attributedSubstringFromRange:NSMakeRange(position,
                                                                             self.attributedText.length - position)];
    
    NSMutableAttributedString *conts = [[NSMutableAttributedString alloc] initWithString:@"" attributes:[self defaultAttributedString]];
    
    if (head)
    {
        [conts appendAttributedString:head];
        [conts appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:[self defaultAttributedString]]];
    }
    
    [conts appendAttributedString:insertingStr];
    
    if (tail)
    {
        [conts appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:[self defaultAttributedString]]];
        [conts appendAttributedString:tail];
    }
    
    return conts;
}

- (NSDictionary*) defaultAttributedString
{
    return @{NSFontAttributeName : self.font};
}



#pragma mark -ETC

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    /*
     Couldn't Cut, Copy, Past
     */
    return NO;
}


- (NSString*) makeStringWithTag
{
    
    //TODO: 새로
    NSMutableAttributedString *workingStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    // Finding Replace ranges and annoations
    [workingStr enumerateAttribute:keyModelId inRange:NSMakeRange(0, workingStr.string.length) options:0
                        usingBlock:^(id value, NSRange range, BOOL *stop) {
                            
                            MintAnnotation *annoation = nil;
                            if (value){
                                annoation = [self annotationForId:value];
                            }
                            
                            if (annoation){
                                NSString *replaceTo = [NSString stringWithFormat:@"<u uid=%@>%@</u>",
                                                       annoation.usr_id,
                                                       annoation.usr_name];
                                [workingStr replaceCharactersInRange:range withString:replaceTo];
                                
                            }
                            
                        }];
    
    return workingStr.string;
    
}

- (void) clearAllAttributedStrings
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributedString removeAttribute: keyModelId range: NSMakeRange(0, self.text.length)];
    [self.annotationList removeAllObjects];
    [self setNeedsDisplay];
    NSLog(@"cleared attributes!");
}


- (void)clearAll
{
    [self clearAllAttributedStrings];
    self.attributedText = [[NSAttributedString alloc]initWithString:@"" attributes:[self defaultAttributedString]];
    [self setNeedsDisplay];
}
@end

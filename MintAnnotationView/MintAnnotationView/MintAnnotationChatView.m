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
}

@end

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
    
    // 3. Find and draw
    
    [self.attributedText enumerateAttribute:keyModelId inRange:NSMakeRange(0, self.attributedText.length)
    options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        
        if (value){
            NSLog(@"%d, %d",range.location, range.length);
            CFRange cfRange = CFRangeMake(range.location, range.length);
            [self calculatingTagRectAndDraw:cfRange];
            
            
        }

    }];
    
}

- (void) calculatingTagRectAndDraw:(CFRange) annoationStringRange
{
    /*
     Caclulating Rect and Draw
     */
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UITextView *textView = self;

    // 4) Find rect
    CFRange stringRange = annoationStringRange;
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
    
    UIImageView *tagImage = [[UIImageView alloc] initWithFrame:rect];
    tagImage.image = self.nameTagImage;
    [self addSubview:tagImage];
    
    UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(rect.origin.x+2, rect.origin.y+2, rect.size.width-4, rect.size.height-4)];
    tagLabel.textColor = _nameTagColor;
    tagLabel.text = nameText;
    tagLabel.backgroundColor = [UIColor clearColor];
    tagLabel.font = [UIFont systemFontOfSize:self.font.pointSize-2];
    tagLabel.textAlignment = NSTextAlignmentCenter;
    tagLabel.minimumScaleFactor = .5;
    [self addSubview:tagLabel];
    
    if (!tagViews)
        tagViews = [[NSMutableArray alloc] init];
    
    [tagViews addObject:tagImage];
    [tagViews addObject:tagLabel];
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
    NSMutableDictionary *attr = [[NSMutableDictionary alloc] initWithDictionary:[self defaultAttributedString]];
    [attr setObject:newAnnoation.usr_id forKey:keyModelId];
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc]
                                             initWithString:[NSString stringWithFormat:@"%@", newAnnoation.usr_name]
                                             attributes:attr];

    NSMutableAttributedString *spaceStringPefix = nil;
    NSString *tempCommentWriting = self.text;

    // display name
    
    // Add Space
    if (tempCommentWriting.length > 0){
        
        NSString *prevString = [tempCommentWriting substringFromIndex:tempCommentWriting.length-1];
        
        if (![prevString isEqualToString:@"\n"])
        {
            spaceStringPefix = [[NSMutableAttributedString alloc] initWithString:@" " attributes:[self defaultAttributedString]];
        }
    }

    NSMutableAttributedString *conts = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    if (spaceStringPefix)
        [conts appendAttributedString:spaceStringPefix];
    [conts appendAttributedString:nameString];
    NSMutableAttributedString *afterBlank = [[NSMutableAttributedString alloc] initWithString:@" "
                                                                                    attributes:[self defaultAttributedString]];
    [conts appendAttributedString:afterBlank];
    

    self.attributedText = conts;
    
    [self setNeedsDisplay];
    
    // Pass Delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:)])
        [self.delegate textViewDidChange:self];
}


// ----


- (NSDictionary*) defaultAttributedString
{
    return @{NSFontAttributeName : [UIFont systemFontOfSize:14]
             };
}


- (void) checkTagDeleting
{
    [self setNeedsDisplay];
   
//    NSLog(@"changed invoked >%@<", self.attributedText.string);
    return;
    
}

- (BOOL) shouldChangeTextInRange:(NSRange)editingRange replacementText:(NSString *)text
{
    
    __block BOOL result = YES;
    
    // Checking Trying to insert within tag
    if (text.length > 0)
    {
        NSRange rangeOfCheckingEditingInTag = editingRange;
        if (rangeOfCheckingEditingInTag.length  == 0) // Insert
        {
            if (rangeOfCheckingEditingInTag.location + rangeOfCheckingEditingInTag.length <= self.attributedText.length)
            {
                rangeOfCheckingEditingInTag.length = 1;
                rangeOfCheckingEditingInTag.location-=1;
                
                //
                if (rangeOfCheckingEditingInTag.location + rangeOfCheckingEditingInTag.length > self.attributedText.length)
                {
                    rangeOfCheckingEditingInTag = NSMakeRange(0, 0);
                }
            }
            
            
        }
        
        [self.attributedText enumerateAttributesInRange:rangeOfCheckingEditingInTag options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            
            if ([attrs objectForKey:keyModelId] && [[attrs objectForKey:keyModelId] length] > 0)
            {
                NSLog(@"------- Editing In Tag");
                result = NO;
            }
            
        }];
        
        
        return result;
    }
    // Deleting
    else
    {
        editingRange.location-=1;
        if (editingRange.location == -1) editingRange.location = 0;
        NSLog(@"editingRange :%d, %d",editingRange.location, editingRange.length);
        
        [self.attributedText enumerateAttributesInRange:editingRange options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            
            if ([attrs objectForKey:keyModelId] && [[attrs objectForKey:keyModelId] length] > 0)
            {
                
                NSRange tagRange = [self findTagPosition:[self annotationForId:[attrs objectForKey:keyModelId]]];
                
                NSLog(@"Deleted annotation tag >>>>> id(%@):range(%d,%d)",[attrs objectForKey:keyModelId], tagRange.location, tagRange.length);
                
                self.attributedText = [self attributedStringWithCutOutOfRange:tagRange];
                self.selectedRange = NSMakeRange(tagRange.location, 0);
                
                [self.annotationList removeObject:[self annotationForId:[attrs objectForKey:keyModelId]]];
                [self setNeedsDisplay];
            }
            
        }];
        
        return YES;

    }
    
}

- (NSAttributedString *) attributedStringWithCutOutOfRange:(NSRange)cuttingRange
{
    NSLog(@"%@",[self.attributedText string]);
    
    NSAttributedString *head = nil;
    if (cuttingRange.location > 0 && cuttingRange.length > 0)
        head = [self.attributedText attributedSubstringFromRange:NSMakeRange(0, cuttingRange.location-1)];
    else
        head = [[NSMutableAttributedString alloc] initWithString:@"" attributes:[self defaultAttributedString]];
    
    
    NSLog(@"%@",[self.attributedText string]);
    
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
    
    
    
    NSLog(@"%@",[self.attributedText string]);
}


//- (NSInteger) findChangedPoint: (NSString*)origin andModified :(NSString*) comparison
//{
//    // Return Region pos of tow text
//    
//    NSInteger point = 0;
//    
//    for (point = 0; point < origin.length; point++) {
//        
//        if (comparison.length <= point || origin.length <= point) break;
//        
//        // Occur a diff
//        if (![[origin substringToIndex:point] isEqualToString:[comparison substringToIndex:point]]) break;
//        
//    }
//    
//    return point;
//}


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return NO;
}
@end

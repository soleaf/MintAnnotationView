//
//  MintAnnotationView.m
//  MintAnnotationView
//
//  Created by soleaf on 13. 8. 26..
//  Mintcode.org
//  http://www.mintcode.org/
//  Repository : https://github.com/soleaf/MintAnnotationVIew
//
#import "MintAnnotationMemoView.h"

@implementation MintAnnotationMemoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeRedraw;
        self.editable = NO;
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
    
    for (NSDictionary *item in self.annotationList) {
        
        // 1) Find rect
        NSInteger beginOnItem = [[item objectForKey:@"start"] integerValue];
        NSInteger tagLength = [[item objectForKey:@"end"] integerValue]-beginOnItem +1;
        UITextPosition *begin = [textView positionFromPosition:textView.beginningOfDocument offset:beginOnItem];
        UITextPosition *end = [textView positionFromPosition:begin offset:tagLength];
        UITextRange *textRange = [textView textRangeFromPosition:begin toPosition:end];

        
        // 3) Need it 2lines ?
        CGPoint firstLineBeginPosition = [textView caretRectForPosition:begin].origin;
        CGPoint secondLineEndPosition = [textView caretRectForPosition:end].origin;
        
        if (firstLineBeginPosition.y < secondLineEndPosition.y){
            
            // Find char pos of 2nd line
            float secondY = firstLineBeginPosition.y;
            CFRange secondStrRange = CFRangeMake(beginOnItem, 1);
            NSInteger secondPos = beginOnItem;
            NSInteger cnt = 0;
            
            while (secondY < secondLineEndPosition.y) {
                
                secondPos++;
                cnt++;
                
                secondStrRange = CFRangeMake(secondPos, tagLength - cnt);
                UITextPosition *secondBegin = [textView positionFromPosition:textView.beginningOfDocument offset:secondStrRange.location];
                CGPoint secondPosition = [textView caretRectForPosition:secondBegin].origin;
                secondY = secondPosition.y;
                
            }
            
            // Calculate a rect
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
            // 2) Draw rect first line
            [self drawTag:context Rect:[textView firstRectForRange:textRange] name:[self textInRange:textRange]];
        }
        
        
    }
    
} // End of if statement for checking name is included in annotation list


- (void) drawTag: (CGContextRef) context Rect:(CGRect) rect name:(NSString*)nameText
{
    if(self.nameTagImage)
        [self drawTagImageInRect:rect name:nameText];
    else
        [self drawRectangle:context Rect:rect];
}


- (void) drawRectangle: (CGContextRef) context Rect:(CGRect) rect
{
    rect.size.width+=2;
    rect.size.height-=2;
    rect.origin.x-=1;
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
    
    if (rect.origin.y ==-1) rect.origin.y= 0;
    
    if (_nameTagColor == nil)
        self.nameTagColor = [UIColor colorWithRed:0.00 green:0.54 blue:0.50 alpha:1.0];

    UIImageView *tagImage = [[UIImageView alloc] initWithFrame:rect];
    tagImage.image = self.nameTagImage;
    tagImage.tag = 9;
    [self addSubview:tagImage];

    CGRect titleRect = rect;
    titleRect.origin.y -=1;
    UIButton *tagButton = [[UIButton alloc] initWithFrame:titleRect];
    [tagButton setTitleColor:_nameTagColor forState:UIControlStateNormal];
    [tagButton setTitle:nameText forState:UIControlStateNormal];
    [tagButton setBackgroundColor:[UIColor clearColor]];
    tagButton.titleLabel.font = [UIFont systemFontOfSize:self.font.pointSize-2];
    tagButton.tag = 9;
    [tagButton addTarget:self action:@selector(touchedTag:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:tagButton];
    
}

- (void) touchedTag:(id) sender
{
    if (self.delegate != nil){
        UIButton * tagButton = (UIButton*) sender;
        [self.delegate touchedMintAnnotationTag:tagButton.titleLabel.text];
    }
}

- (NSString *)annotationWithMemo:(NSString *)memo
{
    
    // 1. Separate plain text, annotation name
    NSMutableArray *announcedNames = [[NSMutableArray alloc] init];
    BOOL isEndOfMemo = NO;
    NSString *parsingMemo = memo;
    
    while (!isEndOfMemo) {
        
        NSString *preParsedMemo = @"";
        
        // 1) start tag
        NSRange rangeOfTagStart = [parsingMemo rangeOfString:@"<u uid="];
        
        if (rangeOfTagStart.location == NSNotFound) {
            isEndOfMemo = YES;
            break;
        }
        
        // 2) Remove start tag
        NSRange rangeOfTagStartClose = [parsingMemo rangeOfString:@">"];
        
        NSString *userName = [parsingMemo substringWithRange:NSMakeRange(rangeOfTagStartClose.location+1 ,
                                                                         ([parsingMemo rangeOfString:@"</u>"].location-1) - rangeOfTagStartClose.location)];
        
        // conetns =  ...<u uid=1111>name</u>...
        if (rangeOfTagStart.location > 0) {
            parsingMemo = [NSString stringWithFormat:@"%@%@",
                           [parsingMemo substringToIndex:rangeOfTagStart.location],
                           [parsingMemo substringFromIndex:rangeOfTagStartClose.location+1]];
        }
        // contents = <u uid=1111>name</u>...
        else{
            parsingMemo = [NSString stringWithFormat:@"%@",
                           [parsingMemo substringFromIndex:rangeOfTagStartClose.location+1]];
        }
        
        // 3)end tag
        NSRange rangeOfTagEnd = [parsingMemo rangeOfString:@"</u>"];
        
        
        // 4) cut end tags
        parsingMemo = [NSString stringWithFormat:@"%@%@%@",
                       preParsedMemo,
                       [parsingMemo substringToIndex:rangeOfTagEnd.location],
                       [parsingMemo substringFromIndex:rangeOfTagEnd.location + rangeOfTagEnd.length]];
        
        
        // 5) Make announced name dic.
        NSDictionary *announcedNameSet = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          [NSNumber numberWithInteger:rangeOfTagStart.location], @"start",
                                          [NSNumber numberWithInteger:rangeOfTagEnd.location-1], @"end",
                                          userName, @"usrName",
                                          nil];
        
        if(announcedNames == nil) announcedNames = [[NSMutableArray alloc] init];
        [announcedNames addObject:announcedNameSet];
        
    }
    
    
    
    // 2. Set plane text
    self.text = parsingMemo.copy;
    //    CGRect frame = self.ui_comment.frame;
    //    frame.size.height = self.ui_comment.contentSize.height-8;
    //    self.ui_comment.frame = frame;
    
    // 3. announced name
    self.annotationList = announcedNames;
    [self setNeedsDisplay];
    
    return parsingMemo;
}


- (void)removeAnnotations
{
    for (UIView *subView in self.subviews) {
        
        if (subView.tag == 9) [subView removeFromSuperview];
    }
}
@end

//
//  ConsoleWindowController.m
//  SAS-Commander
//
//  Created by Steven Christe on 9/6/13.
//  Copyright (c) 2013 Steven Christe. All rights reserved.
//

#import "ConsoleWindowController.h"

@interface ConsoleWindowController ()
- (void)copyToClipboard:(NSString*)str;
@end

@implementation ConsoleWindowController

@synthesize lineNumber;
@synthesize ConsoleTextView;

- (id)init{
    return [super initWithWindowNibName:@"ConsoleWindowController"];
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        if (self) {
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(print_notification:) name:@"LogMessage" object:nil];
            self.lineNumber = 1;
        }
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)clear_button:(NSButton *)sender{
    lineNumber = 0;
	[self.ConsoleTextView setString:@""];
}

- (IBAction)copy_button:(NSButton*)sender{
    [self copyToClipboard:[self.ConsoleTextView string]];
}

-(void)copyToClipboard:(NSString*)str
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSArray *types = [NSArray     arrayWithObjects:NSStringPboardType, nil];
    [pb declareTypes:types owner:self];
    [pb setString: str forType:NSStringPboardType];
}

- (void) print_notification:(NSNotification *)note{
    NSDictionary *notifData = [note userInfo];
    NSString *message;
    message = [notifData valueForKey:@"message"];
    [self log:message];
}

- (void) log:(NSString*) msg
{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *lineHeader = [NSString stringWithFormat:@"[%03i %@] ",lineNumber,[dateFormatter stringFromDate:now]];
    
    NSString *text = [lineHeader stringByAppendingString:[msg stringByAppendingString:@"\n"]];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange selectedRange = NSMakeRange(0, [lineHeader length]); // 4 characters, starting at index 22
    
    [string beginEditing];
    [string addAttribute:NSFontAttributeName
                   value:[NSFont fontWithName:@"Helvetica-Bold" size:12.0]
                   range:selectedRange];
    [string endEditing];
    
    [[self.ConsoleTextView textStorage] insertAttributedString:string atIndex:[[self.ConsoleTextView string] length]];
    
    // scroll to bottom
    NSRange range;
    range = NSMakeRange ([[self.ConsoleTextView textStorage] length], 0);
	[self.ConsoleTextView scrollRangeToVisible:range];
    lineNumber++;
}


@end

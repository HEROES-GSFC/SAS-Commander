//
//  ConsoleWindowController.h
//  SAS-Commander
//
//  Created by Steven Christe on 9/6/13.
//  Copyright (c) 2013 Steven Christe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ConsoleWindowController : NSWindowController

@property (nonatomic) int lineNumber;
@property (unsafe_unretained) IBOutlet NSTextView *ConsoleTextView;
- (IBAction)clear_button:(NSButton *)sender;
- (IBAction)copy_button:(NSButton*)sender;

- (void) log:(NSString*) msg;

@end

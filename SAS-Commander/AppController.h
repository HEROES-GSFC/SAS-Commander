//
//  AppController.h
//  SAS-Commander
//
//  Created by Steven Christe on 8/27/13.
//  Copyright (c) 2013 Steven Christe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppController : NSObject<NSTextViewDelegate>

@property (weak) IBOutlet NSComboBox *commandListcomboBox;
@property (weak) IBOutlet NSTextField *commandKey_textField;
@property (weak) IBOutlet NSForm *Variables_Form;
@property (weak) IBOutlet NSTextField *commandCount_textField;
@property (weak) IBOutlet NSTextField *destinationIP_textField;
@property (weak) IBOutlet NSButton *send_Button;
@property (weak) IBOutlet NSButton *confirm_Button;
@property (weak) IBOutlet NSTextField *timerLabel;
@property (weak) IBOutlet NSSegmentedControl *targetList;

- (IBAction)commandList_action:(NSComboBox *)sender;
- (IBAction)send_Button:(NSButton *)sender;
- (IBAction)cancel_Button:(NSButton *)sender;
- (IBAction)ConfirmButtonPushed:(NSButton *)sender;
- (IBAction)ChoseTargetSystem:(NSSegmentedControl *)sender;
- (IBAction)SwitchNetwork:(NSPopUpButton *)sender;

@end

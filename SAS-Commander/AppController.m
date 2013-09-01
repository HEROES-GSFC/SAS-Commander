//
//  AppController.m
//  SAS-Commander
//
//  Created by Steven Christe on 8/27/13.
//  Copyright (c) 2013 Steven Christe. All rights reserved.
//

#import "AppController.h"
#import "Commander.h"

#define COUNTDOWNSECONDS 6

#define SAS_CMD_GROUND_PORT 2001 /* The command port on the ground network */
#define SAS_CMD_FLIGHT_PORT 2000 /* The command port on the flight network */

@interface AppController()
@property (nonatomic, strong) NSDictionary *plistDict;
@property (nonatomic, strong) Commander *commander;
@property (nonatomic, strong) NSDictionary *listOfCommands;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) int CountDownSeconds;
@property (nonatomic) int sendToPort;
- (void)updateCommandKeyBasedonTargetSystem:(NSString *)target_system;
- (void)updateTimerLabel;
@end

@implementation AppController

@synthesize commandListcomboBox;
@synthesize commandKey_textField;
@synthesize Variables_Form;
@synthesize destinationIP_textField;
@synthesize commander = _commander;
@synthesize send_Button;
@synthesize targetListcomboBox;
@synthesize timer;
@synthesize timerLabel;
@synthesize CountDownSeconds;
@synthesize sendToPort;

- (Commander *)commander
{
    if (_commander == nil) {
        _commander = [[Commander alloc] init];
    }
    return _commander;
}

- (id)init
{
    self = [super init];
    if (self) {
        // read command list dictionary from the CommandList.plist resource file
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        self.CountDownSeconds = COUNTDOWNSECONDS;
        //self.listOfCommands = [[NSDictionary alloc] init];
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CommandList" ofType:@"plist"];
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        self.listOfCommands = (NSDictionary *)[NSPropertyListSerialization
                                               propertyListFromData:plistXML
                                               mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                               format:&format
                                               errorDescription:&errorDesc];
        self.sendToPort = SAS_CMD_GROUND_PORT;
    }
    return self;
}

-(void)awakeFromNib{
    
    NSArray *sortedArray=[[self.listOfCommands allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self.commandListcomboBox addItemsWithObjectValues:sortedArray];
    [self.commandListcomboBox setNumberOfVisibleItems:15];
    [self.commandListcomboBox setCompletes:YES];
    
    [self.send_Button setEnabled:NO];
    [self.confirm_Button setEnabled:YES];
    [self.targetListcomboBox selectItemAtIndex:0];
    [self.destinationIP_textField setStringValue:@"192.168.0.100"];
    
    //for (int i = 0; i < [self.Variables_Form numberOfRows]; i++) {
    //    [[self.Variables_Form cellAtIndex:i] setEnabled:NO];
    //}
}

-(void)controlTextDidChange:(NSNotification *)notification {
    id ax = NSAccessibilityUnignoredDescendant(self.commandListcomboBox);
    [ax accessibilitySetValue: [NSNumber numberWithBool: YES]
                 forAttribute: NSAccessibilityExpandedAttribute];
}

- (IBAction)ConfirmButtonPushed:(NSButton *)sender {
    [self.send_Button setEnabled:YES];
    [self.confirm_Button setEnabled:NO];
    [self.commandListcomboBox setEnabled:NO];
    [self.commandListcomboBox setTextColor:[NSColor redColor]];
    [self.targetListcomboBox setEnabled:NO];
}

- (IBAction)commandList_action:(NSComboBox *)sender {
    NSString *user_choice = [self.commandListcomboBox stringValue];
    if ([self.listOfCommands objectForKey:user_choice] !=nil) {
        
        NSString *command_key = [[self.listOfCommands valueForKey:user_choice] valueForKey:@"key"];
        [self.commandKey_textField setStringValue: command_key];
        
        NSArray *variable_names = [[self.listOfCommands valueForKey:user_choice] valueForKey:@"var_names"];
        NSInteger numberOfVariablesNeeded = [variable_names count];
        [self updateCommandKeyBasedonTargetSystem:[self.targetListcomboBox stringValue]];
        
        // clear the form of all elements
        for (int i = 0; i < [self.Variables_Form numberOfRows]; i++) {
            //[[self.Variables_Form cellAtIndex:i] setEnabled:NO];
            [[self.Variables_Form cellAtIndex:i] setTitle:[NSString stringWithFormat:@"Field %i", i]];
            if (i < numberOfVariablesNeeded) {
                //[[self.Variables_Form cellAtIndex:i] setEnabled:YES];
                [[self.Variables_Form cellAtIndex:i] setTitle:[variable_names objectAtIndex:i]];
            } else {
                [[self.Variables_Form cellAtIndex:i] setTitle:@"NA"];
            }
        }
        NSString *toolTip = (NSString *)[[self.listOfCommands valueForKey:user_choice] valueForKey:@"description"];
        [self.commandListcomboBox setToolTip:toolTip];
        [self.confirm_Button setEnabled:YES];
    }
}

- (IBAction)ChoseTargetSystem:(NSComboBox *)sender {
    NSString *target_system = [sender stringValue];
    [self updateCommandKeyBasedonTargetSystem:target_system];
}

- (IBAction)SwitchNetwork:(NSPopUpButton *)sender {
    if ([sender.selectedItem.title isEqualToString:@"Flight"]) {
        self.sendToPort = SAS_CMD_FLIGHT_PORT;
        [self.timerLabel setStringValue:@" "];
    }
    if ([sender.selectedItem.title isEqualToString:@"Ground"]) {
        self.sendToPort = SAS_CMD_GROUND_PORT;
        [self.timerLabel setStringValue:@"--"];
    }
}

- (void)updateCommandKeyBasedonTargetSystem:(NSString *)target_system {
    NSString *command_key = [self.commandKey_textField stringValue];
    if ([target_system isEqualToString:@"SAS 1"]) {
        self.commandKey_textField.stringValue = [command_key stringByReplacingCharactersInRange:NSMakeRange(2, 1) withString:@"1"];
    }
    if ([target_system isEqualToString:@"SAS 2"]) {
        self.commandKey_textField.stringValue = [command_key stringByReplacingCharactersInRange:NSMakeRange(2, 1) withString:@"2"];
    }
    if ([target_system isEqualToString:@"Both"]) {
        self.commandKey_textField.stringValue = [command_key stringByReplacingCharactersInRange:NSMakeRange(2, 1) withString:@"3"];
    }
}

- (IBAction)send_Button:(NSButton *)sender {
    uint16_t command_sequence_number = 0;
    unsigned command_key;
    NSScanner *scanner = [NSScanner scannerWithString:[self.commandKey_textField stringValue]];
    [scanner scanHexInt:&command_key];
    
    NSString *user_choice = [self.commandListcomboBox stringValue];
    
    NSArray *variable_names = [[self.listOfCommands valueForKey:user_choice] valueForKey:@"var_names"];
    
    NSArray *variable_types = [[self.listOfCommands valueForKey:user_choice] valueForKey:@"var_types"];
    
    NSInteger numberOfVariablesNeeded = [variable_names count];
    
    if (numberOfVariablesNeeded == 0) {
        command_sequence_number = [self.commander send:(uint16_t)command_key :nil :nil :[self.destinationIP_textField stringValue] :self.sendToPort];
    } else {
        NSMutableArray *variables = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < numberOfVariablesNeeded; i++) {
            [variables addObject:[NSNumber numberWithFloat:[[self.Variables_Form cellAtIndex:i] floatValue]]];
        }
        command_sequence_number = [self.commander send:(uint16_t)command_key :[variables copy] :[variable_types copy] :[self.destinationIP_textField stringValue] :self.sendToPort];
    }
    
    [self.commandCount_textField setIntegerValue:command_sequence_number];
    [self.send_Button setEnabled:NO];
    [self.confirm_Button setEnabled:NO];
    [self.commandListcomboBox setEnabled:YES];
    [self.targetListcomboBox setEnabled:YES];
    [self.destinationIP_textField setEnabled:YES];
    [self.commandListcomboBox setTextColor:[NSColor blackColor]];
    if (self.sendToPort == SAS_CMD_GROUND_PORT) {
        self.CountDownSeconds = COUNTDOWNSECONDS;
        self.timerLabel.stringValue = [NSString stringWithFormat:@"%d sec", self.CountDownSeconds];
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimerLabel) userInfo:nil repeats:YES];
    }
}

- (IBAction)cancel_Button:(NSButton *)sender {
    [self.send_Button setEnabled:NO];
    [self.confirm_Button setEnabled:NO];
    [self.Variables_Form setEnabled:YES];
    [self.commandListcomboBox setEnabled:YES];
    [self.targetListcomboBox setEnabled:YES];
    [self.destinationIP_textField setEnabled:YES];
}

- (void)updateTimerLabel{
    self.CountDownSeconds--;
    self.timerLabel.stringValue = [NSString stringWithFormat:@"%d sec", self.CountDownSeconds];
    if (self.CountDownSeconds == -1) {
        [self.timerLabel setStringValue:@"--"];
        [self.timer invalidate];
    }
}


@end

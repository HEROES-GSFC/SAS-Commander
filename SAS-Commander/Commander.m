//
//  Commander.m
//  SAS-Commander
//
//  Created by Steven Christe on 8/27/13.
//  Copyright (c) 2013 Steven Christe. All rights reserved.
//

#import "Commander.h"
#include "Command.hpp"
#include "UDPSender.hpp"

@interface Commander()
@property (nonatomic) uint16_t frame_sequence_number;
@end

@implementation Commander

@synthesize frame_sequence_number;

- (id)init{
    self = [super init]; // call our super’s designated initializer
    if (self) {
        // initialize our subclass here
        self.frame_sequence_number = 0;
    }
    return self;
}

-(uint16_t)send :(uint16_t)command_key :(NSArray *)command_variables :(NSString *)ip_address :(uint) port{
    CommandSender comSender = CommandSender( [ip_address UTF8String], port );
    CommandPacket cp(0x30, self.frame_sequence_number);
    Command cm(0x10ff, command_key);
    if (command_variables != nil) {
        for (NSNumber *variable in command_variables) {
            cm << (uint16_t)[variable intValue];
        }
    }
    try{
        cp << cm;
    } catch (std::exception& e) {
        std::cerr << e.what() << std::endl;
    }
    
    comSender.send( &cp );
    comSender.close_connection();
    
    // update the frame number every time we send out a packet
    self.frame_sequence_number++;
    return self.frame_sequence_number;
}

@end

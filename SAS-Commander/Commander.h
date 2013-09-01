//
//  Commander.h
//  SAS-Commander
//
//  Created by Steven Christe on 8/27/13.
//  Copyright (c) 2013 Steven Christe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Commander : NSObject

-(uint16_t)send:(uint16_t)command_key :(NSArray *) command_variables :(NSArray *) command_types :(NSString *) ip_address :(uint) port;

@end

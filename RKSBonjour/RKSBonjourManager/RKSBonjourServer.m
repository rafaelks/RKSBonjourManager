//
//  RKSBonjourServer.m
//  RKSBonjour
//
//  Created by Rafael Kellermann Streit on 7/22/14.
//  Copyright (c) 2014 rafaelks. All rights reserved.
//

#import "RKSBonjourServer.h"

@implementation RKSBonjourServer

- (instancetype)initWithName:(NSString *)name
{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *type = ([info objectForKey:@"RKSBonjourManagerServiceName"]) ? [info objectForKey:@"RKSBonjourManagerServiceName"] : @"_RKSBonjour._tcp.";
    
    if (self = [super initWithBonjourType:type]) {
        _name = name;
    }
    
    return self;
}

- (void)connection:(DTBonjourDataConnection *)connection didReceiveObject:(id)object
{
	[super connection:connection didReceiveObject:object];
	
	for (DTBonjourDataConnection *_connection in self.connections) {
		if (_connection != connection) {
			[_connection sendObject:object error:NULL];
		}
	}
}

@end

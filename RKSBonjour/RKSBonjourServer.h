//
//  RKSBonjourServer.h
//  RKSBonjour
//
//  Created by Rafael Kellermann Streit on 7/22/14.
//  Copyright (c) 2014 rafaelks. All rights reserved.
//

#import "DTBonjourServer.h"

@interface RKSBonjourServer : DTBonjourServer

@property (nonatomic, readonly) NSString *name;

- (instancetype)initWithName:(NSString *)name;

@end

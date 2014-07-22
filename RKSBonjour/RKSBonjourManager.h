//
//  RKSBonjourManager.h
//  RKSBonjour
//
//  Created by Rafael Kellermann Streit on 7/22/14.
//  Copyright (c) 2014 rafaelks. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RKSBonjourServer.h"
#import "RKSBonjourClient.h"

@protocol RKSBonjourManagerDelegate <NSObject>
@optional

- (void)server:(DTBonjourServer *)server didReceiveObject:(id)object onConnection:(DTBonjourDataConnection *)connection;
- (void)client:(DTBonjourDataConnection *)connection didReceiveObject:(id)object;
- (void)connectionDidClose:(DTBonjourDataConnection *)connection;

@end

@interface RKSBonjourManager : NSObject

@property (nonatomic, weak) id <RKSBonjourManagerDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *servers;

+ (RKSBonjourManager *)sharedManager;

- (void)addDelegate:(id <RKSBonjourManagerDelegate>)object;
- (void)removeDelegate:(id <RKSBonjourManagerDelegate>)object;

- (RKSBonjourServer *)createServerWithName:(NSString *)name;
- (RKSBonjourClient *)createClientWithServer:(NSNetService *)service;

@end

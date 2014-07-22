//
//  RKSBonjourManager.m
//  RKSBonjour
//
//  Created by Rafael Kellermann Streit on 7/22/14.
//  Copyright (c) 2014 rafaelks. All rights reserved.
//

#import "RKSBonjourManager.h"

@interface RKSBonjourManager () <NSNetServiceBrowserDelegate, NSNetServiceDelegate, DTBonjourDataConnectionDelegate, DTBonjourServerDelegate>

@property (nonatomic, strong) NSMutableSet *unidentifiedServices;

@property (nonatomic, strong) NSNetServiceBrowser *service;
@property (nonatomic, strong) NSMutableArray *delegates;

@end

@implementation RKSBonjourManager

+ (RKSBonjourManager *)sharedManager
{
	static RKSBonjourManager *_default = nil;
	static dispatch_once_t safer;
	
	if (_default != nil) {
		return _default;
	}
	
	dispatch_once(&safer, ^(void) {
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *name = ([info objectForKey:@"RKSBonjourManagerServiceName"]) ? [info objectForKey:@"RKSBonjourManagerServiceName"] : @"_RKSBonjour._tcp.";
        NSString *domain = ([info objectForKey:@"RKSBonjourManagerDomain"]) ? [info objectForKey:@"RKSBonjourManagerDomain"] : @"";
        
		_default = [[RKSBonjourManager alloc] initWithServiceName:name andDomain:domain];
	});
	
	return _default;
}

- (instancetype)initWithServiceName:(NSString *)name andDomain:(NSString *)domain
{
    if (self = [super init]) {
        [self.service setDelegate:self];
        [self.service searchForServicesOfType:name inDomain:domain];
    }
    
    return self;
}

#pragma mark - Lazy

- (NSNetServiceBrowser *)service
{
    if (!_service) {
        _service = [[NSNetServiceBrowser alloc] init];
    }
    
    return _service;
}

- (NSMutableSet *)unidentifiedServices
{
    if (!_unidentifiedServices) {
        _unidentifiedServices = [[NSMutableSet alloc] init];
    }
    
    return _unidentifiedServices;
}

- (NSMutableArray *)servers
{
    if (!_servers) {
        _servers = [[NSMutableArray alloc] init];
    }
    
    return _servers;
}

- (NSMutableArray *)delegates
{
	if (!_delegates) {
		_delegates = [[NSMutableArray alloc] init];
	}
	
	return _delegates;
}

#pragma mark - Delegate Getters/Setters

- (void)addDelegate:(id <RKSBonjourManagerDelegate>)object
{
	NSValue *pointerToDelegate = [NSValue valueWithPointer:CFBridgingRetain(object)];
	[self.delegates addObject:pointerToDelegate];
}

- (void)removeDelegate:(id <RKSBonjourManagerDelegate>)object
{
	NSValue *pointerToDelegate = [NSValue valueWithPointer:CFBridgingRetain(object)];
    [self.delegates removeObject:pointerToDelegate];
}

#pragma mark - Manage found objects

- (void)updateFoundServices
{
	for (NSNetService *service in [self.unidentifiedServices copy]) {
		NSDictionary *dict = [NSNetService dictionaryFromTXTRecordData:service.TXTRecordData];
		
		if (!dict) {
			continue;
		}
		
        [self.servers addObject:service];
		
		[self.unidentifiedServices removeObject:service];
	}
}

#pragma mark - NSNetService Delegate

- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data
{
	[self updateFoundServices];
	[sender stopMonitoring];
}

#pragma mark - NetServiceBrowserDelegate

- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream
{
     // RKS NOTE: This implementations must exists because BonjourChatServer - (id)initWithService:(NSNetService *)service super method.
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
           didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	[aNetService setDelegate:self];
	[aNetService startMonitoring];
    
	[self.unidentifiedServices addObject:aNetService];
    
	if (!moreComing) {
		[self updateFoundServices];
	}
    
    NSLog(@"Server Found: %@", aNetService);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
         didRemoveService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing
{
	[self.servers removeObject:aNetService];
	[self.unidentifiedServices removeObject:aNetService];
    
	if (!moreComing) {
        [self updateFoundServices];
	}
    
    NSLog(@"Server Removed: %@", aNetService);
}

#pragma mark - DTBonjourServer Delegate (Server)

- (void)bonjourServer:(DTBonjourServer *)server didReceiveObject:(id)object onConnection:(DTBonjourDataConnection *)connection
{
    for (NSValue *val in self.delegates) {
        id <RKSBonjourManagerDelegate> delegate = [val pointerValue];
		
		if ([delegate respondsToSelector:@selector(server:didReceiveObject:onConnection:)]) {
			[delegate server:server didReceiveObject:object onConnection:connection];
		}
    }
    
    NSLog(@"Server received a message: %@", object);
}

#pragma mark - DTBonjourConnection Delegate (Client)

- (void)connection:(DTBonjourDataConnection *)connection didReceiveObject:(id)object
{
    for (NSValue *val in self.delegates) {
        id <RKSBonjourManagerDelegate> delegate = [val pointerValue];
		
		if ([delegate respondsToSelector:@selector(client:didReceiveObject:)]) {
			[delegate client:connection didReceiveObject:object];
		}
    }
    
	NSLog(@"Clients received a message: %@", object);
}

- (void)connectionDidClose:(DTBonjourDataConnection *)connection
{
    for (NSValue *val in self.delegates) {
        id <RKSBonjourManagerDelegate> delegate = [val pointerValue];
		
		if ([delegate respondsToSelector:@selector(connectionDidClose:)]) {
			[delegate connectionDidClose:connection];
		}
    }
    
    NSLog(@"Connection with server was closed: %@", connection);
}

#pragma mark - Servers & Clients managements

- (RKSBonjourServer *)createServerWithName:(NSString *)name
{
    RKSBonjourServer *server = [[RKSBonjourServer alloc] initWithName:name];
    server.delegate = self;
    return server;
}

- (RKSBonjourClient *)createClientWithServer:(NSNetService *)service
{
    RKSBonjourClient *client = [[RKSBonjourClient alloc] initWithService:service];
    client.delegate = self;
    return client;
}

@end

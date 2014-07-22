//
//  RKSMainViewController.m
//  RKSBonjour
//
//  Created by Rafael Kellermann Streit on 7/18/14.
//  Copyright (c) 2014 rafaelks. All rights reserved.
//

#import "RKSMainViewController.h"

#import "RKSBonjourManager.h"

@interface RKSMainViewController () <RKSBonjourManagerDelegate>

@property (nonatomic, strong) DTBonjourServer *server;

@property (nonatomic, strong) RKSBonjourManager *bonjourManager;

@end

@implementation RKSMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setBonjourManager:[RKSBonjourManager sharedManager]];
    [self.bonjourManager addDelegate:self];
    
    [self setServer:[self.bonjourManager createServerWithName:@"Server Name 01"]];
    [self.server start];
}

@end

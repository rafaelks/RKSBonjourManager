# RKSBonjourManager

This a manager that helps you to interact between devices using Bonjour. Easily create Servers & Clients for your application.

## Methods

```objective-c
+ (RKSBonjourManager *)sharedManager;

- (void)addDelegate:(id <RKSBonjourManagerDelegate>)object;
- (void)removeDelegate:(id <RKSBonjourManagerDelegate>)object;

- (RKSBonjourServer *)createServerWithName:(NSString *)name;
- (RKSBonjourClient *)createClientWithServer:(NSNetService *)service;
```

## Protocol

```objective-c
- (void)server:(DTBonjourServer *)server didReceiveObject:(id)object onConnection:(DTBonjourDataConnection *)connection;
- (void)client:(DTBonjourDataConnection *)connection didReceiveObject:(id)object;
- (void)connectionDidClose:(DTBonjourDataConnection *)connection;
```

## Example

There is an Xcode project in this repository as an example to create a server.

# References

* [DTBonjour](https://github.com/Cocoanetics/DTBonjour).
* [... and Bonjour to you, too!](http://www.cocoanetics.com/2012/11/and-bonjour-to-you-too/)

# License (DTBonjour)

It is open source and covered by a standard 2-clause BSD license. That means you have to mention *Cocoanetics* as the original author of this code and reproduce the LICENSE text inside your app.

You can purchase a [Non-Attribution-License](https://www.cocoanetics.com/order/?product_id=DTBonjour) for 75 Euros for not having to include the LICENSE text.
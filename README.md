# GoogleReaderAPI - iOS client

This is an Objective-C wrapper around unofficial GoogleReader API.
I'm open sourcing this library while working on a side project.

Disclaimer: Google has no official API for Google Reader.
This library has been inspired by the Pyrfeed project (a python client).
All endpoints and api methods have been discovered through reverse
engineering. There is NO official documentation neither warranty.
This is a work in progress.

## Features
* Authentication via ClientLogin
* Base low-level methods 
* Response in raw JSON strings

## TODO
* Test case
* High-level API methods
* Encoding of JSON responses into native NSDictionary
* oAuth v2.0 method support (when it will be available)
* Unofficial documentation

## Mini tutorial: use in your project
Warning: make this at your own risk. I remember you this is a
very ALPHA stage.

* Include `"GoogleReader.h"` `"GoogleReader.m"` and `"Constants.h"` in
your XCode Project.
* Check if user is authenticated through class method:
    `[GoogleReader isNeedAuth];`
* Authenticate user:
    `[GoogleReader makeLoginWithUsername:@"username@gmail.com" password:@"password"];`
* Get all Reader subscriptions:
    `[GoogleReader getSubscriptionsList];`
* Add a new subscription:
`[GoogleReader addSubscriptionWithURL:(NSString *)url feed:(NSString *)feed labels:(NSArray *)labels];`

Any help is welcome.

Copyright 2011 Simone Carella.	

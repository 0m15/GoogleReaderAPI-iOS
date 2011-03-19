# GoogleReaderAPI - iOS client

## UPDATES:
* All requests are now Async
* Written all API methods (still need to add OC Unit Test)
* Written a *GoogleReaderRequestDelegate* Protocol
* Refactored all methods (bringed all methods from class methods to instance methods)
* Added JSON parsing with SBJSON library <https://github.com/stig/json-framework/>
This is an Objective-C wrapper around unofficial GoogleReader API.
I'm open sourcing this library while working on a side project.

Disclaimer: Google has no official API for Google Reader.
This library has been inspired by the Pyrfeed project (a python client).
All endpoints and api methods have been discovered through reverse
engineering. There is NO official documentation neither warranty.
This is a work in progress.

## Features
* Authentication via ClientLogin
* Asynchronous requests
* High level API methods 
* JSON responses encoded in NSDictionary

## TODO
* Test case
<strike>* Async all requests/responses</strike>
<strike>* High-level API methods</strike>
<strike>* Encoding of JSON responses into native NSDictionary</strike>
* oAuth v2.0 method support (when it will be available)
* Unofficial documentation

<strike>## Mini tutorial: use in your project
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
`[GoogleReader addSubscriptionWithURL:(NSString *)url feed:(NSString *)feed labels:(NSArray *)labels];`</strike>


Any help is welcome.

Copyright 2011 Simone Carella.	

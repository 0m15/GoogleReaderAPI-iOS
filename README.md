# Attention please
I'm not commiting any more on this project. It all started as a game of a one bored night. It's buggy and misses Unit Tests.
If you'd want to mantain it, please do a Fork, fixes the issues and I'd be very glad to merge it back as the master.

# Donate

If this project helped you/your organization or you want to offer me a beer, feel free to donate to this Bitcoin address:

    1321VwpBy9vdMwxKBFi5c2jVD4wfdDUJfY


# GoogleReaderAPI - iOS client

An Objective-C wrapper around (unofficial) Google Reader API for iOS Apps. 

This is an Objective-C wrapper around unofficial GoogleReader API.
I'm open sourcing this library while working on a side project.

*DISCLAIMER:* Google has no official API for Google Reader.
This library has been inspired by the Pyrfeed project (a python client).
All endpoints and api methods have been discovered through reverse
engineering. There is NO official documentation neither warranty.
This is a work in progress.

## UPDATES:
* All requests are now Async
* Written all API methods (still need to add OC Unit Test)
* Written a *GoogleReaderRequestDelegate* Protocol
* Refactored all methods (bringed all methods from class methods to instance methods)
* Added JSON parsing with SBJSON library <https://github.com/stig/json-framework/>

## Features
* Authentication via ClientLogin
* Asynchronous requests
* High level API methods 
* JSON responses encoded in NSDictionary

## TODO
* Test case
* <del>Async all requests/responses</del>
* <del>High-level API methods</del>
* <del>Encoding of JSON responses into native NSDictionary</del>
* oAuth v2.0 method support (when it will be available)
* Unofficial documentation

## Mini tutorial: use in your project
Warning: make this at your own risk. I remember you this is a
very ALPHA stage.

* Include `"GoogleReader.h"` `"GoogleReader.m"` and `"Constants.h"` in
your XCode Project.
* Instantiate a new GoogleReader object and set its delegate (remember to implement protocol methods in your delegate):

    `GoogleReader *reader = [GoogleReader alloc] init];`
    `[reader setDelegate:self];` 
* Check if user needs authentication

    `[reader isNeedAuth];`

* API request example: Get all Reader subscriptions

    `[reader getSubscriptionsList];`
* API requext example: Add a new subscription

    `[reader addSubscriptionWithURL:(NSString *)url feed:(NSString *)feed labels:(NSArray *)labels];`</del>


Any help is welcome.

##Authors:
* Aaron Brethorst (<http://github.com/aaronbrethorst>)
* Simone Carella (<http://github.com/zimok>)

Copyright 2011 Simone Carella/Aaron Brethorst.	


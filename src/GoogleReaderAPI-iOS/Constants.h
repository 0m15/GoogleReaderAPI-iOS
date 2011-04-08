//
//  Constants.h
//  GoogleReaderAPI Wrapper for iOS
//
//  Created by Simone Carella on 3/13/11.
//  Copyright 2011 Simone Carella. All rights reserved.
//

// main url endpoints
//#define GOOGLE_CLIENT_AUTH_URL @"https://www.google.com/accounts/ClientLogin?client=googlereader-ios-client"
#define GOOGLE_READER_URL @"http://www.google.com/reader/"
#define GOOGLE_ATOM_URL @"http://www.google.com/reader/atom/"
#define GOOGLE_API_PREFIX_URL @"http://www.google.com/reader/api/0/"
#define GOOGLE_VIEW_URL @"http://www.google.com/reader/view/"
#define QUICK_ADD_URL @"http://www.google.com/reader/api/0/subscription/quickadd"

// url suffixes
#define ATOM_GET_FEED @"feed/"

#define ATOM_PREFIX_USER @"user/-/"
#define ATOM_PREFIX_USER_NUMBER @"user/00000000000000000000/"
#define ATOM_PREFIX_LABEL @"user/-/label"
#define ATOM_PREFIX_STATE_GOOGLE @"user/-/state/com.google/"

#define ATOM_STATE_READ @"user/-/state/com.google/read"
#define ATOM_STATE_UNREAD @"user/-/state/com.google/kept-unread"
#define ATOM_STATE_FRESH @"user/-/state/com.google/fresh"
#define ATOM_STATE_READING_LIST @"user/-/state/com.google/reading-list"
#define ATOM_STATE_BROADCAST @"user/-/state/com.google/broadcast"
#define ATOM_STATE_STARRED @"user/-/state/com.google/starred"
#define ATOM_SUBSCRIPTIONS @"user/-/state/com.google/subscriptions"

#define API_EDIT_SUBSCRIPTIONS @"subscription/edit"
#define API_EDIT_TAG @"edit-tag"

#define API_LIST_PREFERENCES @"preference/list"
#define API_LIST_SUBSCRIPTIONS @"subscription/list"
#define API_LIST_TAG @"tag/list"
#define API_LIST_UNREAD_COUNT @"unread-count"
#define API_TOKEN @"token"


// other keys
#define AGENT @"googlereader-ios-client"

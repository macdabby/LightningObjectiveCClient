//
//  Lightning.m
//  Lightning
//
//  Created by DAB on 4/23/15.
//  Copyright (c) 2015 DAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Lightning.h"

@implementation Lightning

static NSURL *baseURL;
static NSString *sessionKey;
static Boolean debug;

// Save the user's session key.
+(void) setSessionKey: (NSString *)sessionKey {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:sessionKey forKey:@"Lightning.SessionKey"];
    [defaults synchronize];
}

// Get the user's session key.
+(NSString *) getSessionKey {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"Lightning.SessionKey"];
}

+(void) configure: (NSString *)url {
    [self configure: url debug: false];
}

// Load a current session key and set the root path.
+(void) configure: (NSString *)url debug: (Boolean)debugOn {
    // Set the base URL.
    baseURL = [NSURL URLWithString:url];
    debug = debugOn;

    // Load the user's session key.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    sessionKey = [defaults objectForKey:@"Lightning.SessionKey"];
}

+(NSDictionary *) send: (NSString *) method url: (NSURL *) url body: (NSData *) body {
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSString *cookieFormat = debug ? @"%@=%@; XDEBUG_SESSION=PHPSTORM;" : @"%@=%@;";
    NSString *cookieValue = [NSString stringWithFormat:cookieFormat, @"session", sessionKey];
    [request setValue:cookieValue forHTTPHeaderField:@"Cookie"];
    [request setHTTPMethod:method];
    if (body != nil) {
        [request setHTTPBody:body];
    }

    @try {
        // TODO: This should also read the cookie to see if they were logged out.
        NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    @catch (NSException *e) {
        return nil;
    }
}

+(NSDictionary *) GET: (NSString *) url params: (NSDictionary *) params {
    NSData *queryString = [[self serializeParams:params] dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *fullUrl = [NSURL URLWithString:url relativeToURL:baseURL];
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:[fullUrl absoluteString]];
    [components setQuery: [[NSString alloc] initWithData:queryString encoding:NSUTF8StringEncoding]];
    return [Lightning send:@"GET" url:fullUrl body:nil];
}
+(NSDictionary *) GET: (NSString *) url {
    NSURL *fullUrl = [NSURL URLWithString:url relativeToURL:baseURL];
    return [Lightning send:@"GET" url:fullUrl body:nil];
}
+(NSDictionary *) POST: (NSString *) url params: (NSDictionary *) params {
    NSURL *fullUrl = [NSURL URLWithString:url relativeToURL:baseURL];
    return [Lightning send:@"POST" url:fullUrl body:[[self serializeParams:params] dataUsingEncoding:NSUTF8StringEncoding]];
}
+(NSDictionary *) POST: (NSString *) url {
    NSURL *fullUrl = [NSURL URLWithString:url relativeToURL:baseURL];
    return [Lightning send:@"POST" url:fullUrl body:nil];
}
+(NSDictionary *) POST: (NSString *) url JSON: (NSDictionary *) json {
    NSURL *fullUrl = [NSURL URLWithString:url relativeToURL:baseURL];
    return [Lightning send:@"POST" url:fullUrl body:[NSJSONSerialization dataWithJSONObject:json options:0 error:nil]];
}

// Copied from stack overflow:
// http://stackoverflow.com/questions/718429/creating-url-query-parameters-from-nsdictionary-objects-in-objectivec
+ (NSString *)serializeParams:(NSDictionary *)params {
    NSMutableArray *pairs = NSMutableArray.array;
    for (NSString *key in params.keyEnumerator) {
        id value = params[key];
        if ([value isKindOfClass:[NSDictionary class]])
            for (NSString *subKey in value)
                [pairs addObject:[NSString stringWithFormat:@"%@[%@]=%@", key, subKey, [self escapeValueForURLParameter:[value objectForKey:subKey]]]];

        else if ([value isKindOfClass:[NSArray class]])
            for (NSString *subValue in value)
                [pairs addObject:[NSString stringWithFormat:@"%@[]=%@", key, [self escapeValueForURLParameter:subValue]]];

        else
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [self escapeValueForURLParameter:value]]];

    }
    return [pairs componentsJoinedByString:@"&"];
}
+ (NSString *)escapeValueForURLParameter:(NSString *)valueToEscape {
    return (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) valueToEscape,
                                                                                  NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
}

@end

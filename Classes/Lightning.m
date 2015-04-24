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

+(NSDictionary *) send: (NSString *) method url: (NSString *) urlString params: (NSDictionary *) params {
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:baseURL];

    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSString *cookieFormat = debug ? @"%@=%@&XDEBUG_SESSION_START=PHPSTORM;" : @"%@=%@;";
    [request setValue:[NSString stringWithFormat:cookieFormat, @"session", sessionKey] forHTTPHeaderField:@"Cookie"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[self serializeParams:params] dataUsingEncoding:NSUTF8StringEncoding]];

    // TODO: This should also read the cookie to see if they were logged out.
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

+(NSDictionary *) GET: (NSString *) url params: (NSDictionary *) params {
    return [Lightning send:@"POST" url:url params:params];
}
+(NSDictionary *) GET: (NSString *) url {
    return [Lightning send:@"POST" url:url params:@{}];
}
+(NSDictionary *) POST: (NSString *) url params: (NSDictionary *) params {
    return [Lightning send:@"POST" url:url params:params];
}
+(NSDictionary *) POST: (NSString *) url {
    return [Lightning send:@"POST" url:url params:@{}];
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

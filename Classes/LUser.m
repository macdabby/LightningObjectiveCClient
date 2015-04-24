//
//  LUser.m
//  Lightning
//
//  Created by DAB on 4/23/15.
//  Copyright (c) 2015 DAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Luser.h"
#import "Lightning.h"

@implementation LUser

-(instancetype) init {
    LUser *user = [super init];
    [user load];
    return user;
}

// Simple login, returns a new user object without prior sinitialization.
+(instancetype) logIn: (NSString *) email password: (NSString *) password {
    LUser *user = [[LUser alloc] init];
    if ([user isLoggedIn]) {
        [user logOut];
    }
    [user logIn:email password:password];
    return user;
}

// Log in the current user object.
-(Boolean) logIn: (NSString *) email password: (NSString *) password {
    // Log in with the client.
    NSDictionary *response = [Lightning POST: @"/api/user" params: @{@"action": @"login", @"email":email, @"password":password}];
    self.data = [[NSMutableDictionary  alloc] init];

    // Check the status.
    NSString *status = [response objectForKey:@"status"];
    Boolean success = false;
    if (status && [status isEqualToString:@"success"]) {
        // Save the settings.
        success = true;
        self.data = (NSMutableDictionary *)response;
        [self setCookieWithResponse:response];
    }

    return success;
}

+(instancetype) registerWithEmail: (NSString *) email password: (NSString *) password {
    LUser *user = [[LUser alloc] init];
    [user registerWithEmail:email password:password data:@{}];
    return user;
}

+(instancetype) registerWithEmail: (NSString *) email password: (NSString *) password data: (NSDictionary *) data {
    LUser *user = [[LUser alloc] init];
    [user registerWithEmail:email password:password data:data];
    return user;
}

-(void) registerWithEmail: (NSString *) email password: (NSString *) password data: (NSDictionary *) data {
    // Log in with the client.
    NSDictionary *response = [Lightning POST: @"/api/user" params: @{@"action": @"register", @"email":email, @"password":password}];
    self.data = [[NSMutableDictionary  alloc] init];

    // Check the status.
    NSString *status = [response objectForKey:@"status"];
    Boolean success = false;
    if (status && [status isEqualToString:@"success"]) {
        // Save the settings.
        success = true;
        self.data = (NSMutableDictionary *)response;
        [self setCookieWithResponse:response];
    }
}

-(void) setCookieWithResponse: (NSDictionary *) response {
    if (response) {
        response = [response objectForKey:@"cookies"];
        if (response) {
            NSString *sessionKey = [response objectForKey:@"session"];
            [Lightning setSessionKey:sessionKey];
        }
    }
}

-(void) logOut {
    NSDictionary *response = [Lightning POST: @"/api/user" params: @{@"action": @"logout"}];
}

-(Boolean) isLoggedIn {
    return true;
}

-(void) load {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.data = [defaults objectForKey:@"Lightning.User"];
    if (!self.data) {
        self.data = [[NSMutableDictionary alloc] init];
    }
}

-(void) save {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.data forKey:@"Lightning.User"];
    [defaults synchronize];
}


@end

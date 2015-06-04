//
//  Lightning.h
//  Lightning
//
//  Created by DAB on 4/23/15.
//  Copyright (c) 2015 DAB. All rights reserved.
//

#include "LUser.h"

#ifndef Lightning_Lightning_h
#define Lightning_Lightning_h


#endif

@interface Lightning : NSObject

+(void) configure: (NSString *)url;
+(void) configure: (NSString *)url debug: (Boolean)debugOn;
+(void) setSessionKey: (NSString *)sessionKey;
+(NSDictionary *) POST: (NSString *) url;
+(NSDictionary *) POST: (NSString *) url params: (NSDictionary *) params;
+(NSDictionary *) GET: (NSString *) url;
+(NSDictionary *) GET: (NSString *) url params: (NSDictionary *) params;
+(NSDictionary *) POST: (NSString *) url JSON: (NSDictionary *) json;

@end

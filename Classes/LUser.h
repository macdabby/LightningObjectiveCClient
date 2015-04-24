//
//  LUser.h
//  Lightning
//
//  Created by DAB on 4/23/15.
//  Copyright (c) 2015 DAB. All rights reserved.
//

#ifndef Lightning_LUser_h
#define Lightning_LUser_h


#endif

@interface LUser : NSObject

@property (nonatomic) NSMutableDictionary *data;

+(instancetype) logIn: (NSString *) email password: (NSString *) password;
-(Boolean) logIn: (NSString *) email password: (NSString *) password;
+(instancetype) registerWithEmail: (NSString *) email password: (NSString *) password;
+(instancetype) registerWithEmail: (NSString *) email password: (NSString *) password data: (NSDictionary *) data;
-(void) registerWithEmail: (NSString *) email password: (NSString *) password data: (NSDictionary *) data;
-(void) logOut;
-(Boolean) isLoggedIn;
-(void) load;
-(void) save;

@end

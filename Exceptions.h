//
//  Exceptions.h
//  ApkDropZone
//
//  Created by dstd on 13/05/15.
//  Copyright (c) 2015 stdlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Exceptions : NSObject

+ (NSException*)try:(void(^)(void))tryBlock;
+ (void)try:(void(^)(void))tryBlock except:(void(^)(NSException *))exceptBlock;
+ (void)try:(void(^)(void))tryBlock except:(void(^)(NSException *))exceptBlock finally:(void(^)(void))finallyBlock;
@end

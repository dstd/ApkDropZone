//
//  Exceptions.m
//  ApkDropZone
//
//  Created by dstd on 13/05/15.
//  Copyright (c) 2015 stdlabs. All rights reserved.
//

#import "Exceptions.h"

@implementation Exceptions

+ (NSException*)try:(void(^)(void))tryBlock {
    if (!tryBlock)
        return nil;
    
    @try {
        tryBlock();
    }
    @catch (NSException* e) {
        return e;
    }
}

+ (void)try:(void(^)(void))tryBlock except:(void(^)(NSException *))exceptBlock {
    if (!tryBlock)
        return;
    
    @try {
        tryBlock();
    }
    @catch (NSException* e) {
        if (exceptBlock)
            exceptBlock(e);
    }
}

+ (void)try:(void (^)(void))tryBlock except:(void (^)(NSException *))exceptBlock finally:(void (^)(void))finallyBlock {
    if (!tryBlock) {
        if (finallyBlock)
            finallyBlock();
        return;
    }
    
    @try {
        tryBlock();
    }
    @catch (NSException* e) {
        if (exceptBlock)
            exceptBlock(e);
    }
    @finally {
        if (finallyBlock)
            finallyBlock();
    }
}

@end

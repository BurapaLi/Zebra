//
//  ZBBaseRepo.m
//  Zebra
//
//  Created by Wilson Styres on 12/12/19.
//  Copyright © 2019 Wilson Styres. All rights reserved.
//

#import "ZBBaseRepo.h"

#import <ZBDevice.h>

@implementation ZBBaseRepo

@synthesize archiveType;
@synthesize repositoryURL;
@synthesize distribution;
@synthesize components;
@synthesize directoryURL;
@synthesize releaseURL;
@synthesize packagesSaveName;
@synthesize releaseSaveName;
@synthesize debLine;

+ (NSArray *)baseReposFromSourceList:(NSString *)sourceListPath {
    NSError *readError;
    NSString *sourceListContents = [NSString stringWithContentsOfFile:sourceListPath encoding:NSUTF8StringEncoding error:&readError];
    if (readError) {
        NSLog(@"[Zebra] Could not read sources list contents located at %@ reason: %@", sourceListPath, readError.localizedDescription);
        [NSException raise:NSObjectNotAvailableException format:@"Could not read sources list contents located at %@ reason: %@", sourceListPath, readError.localizedDescription];
        
        return NULL;
    }
    
    NSArray *debLines = [sourceListContents componentsSeparatedByString:@"\n"];
    NSMutableArray *baseRepos = [NSMutableArray new];
    for (NSString *debLine in debLines) {
        if (![debLine isEqualToString:@""]) {
            if ([debLine characterAtIndex:0] == '#') continue;
            
            ZBBaseRepo *repo = [[ZBBaseRepo alloc] initFromDebLine:debLine];
            if (repo) {
                [baseRepos addObject:repo];
            }
        }
    }
    
    return baseRepos;
}

- (id)initWithArchiveType:(NSString *)archiveType repositoryURL:(NSString *)repositoryURL distribution:(NSString *)distribution components:(NSArray <NSString *> *)components {
    self = [super init];
    
    if (self) {
        self->archiveType = archiveType;
        self->repositoryURL = repositoryURL;
        self->distribution = distribution;
        self->components = components;
        
        if (![self->distribution isEqualToString:@"./"]) { //Set packages and release URLs to follow dist format
            NSString *mainDirectory = [NSString stringWithFormat:@"%@/dists/%@/%@/%@/", self->repositoryURL, self->distribution, self->components[0], [ZBDevice debianArchitecture]];
            directoryURL = [NSURL URLWithString:mainDirectory];
            releaseURL = [directoryURL URLByAppendingPathComponent:@"/Release"];
        }
        else {
            directoryURL = [NSURL URLWithString:repositoryURL];
            releaseURL = [directoryURL URLByAppendingPathComponent:@"/Release"];
        }
    }
    
    return self;
}

- (id)initFromDebLine:(NSString *)debLine {
    
    NSMutableArray *lineComponents = [[debLine componentsSeparatedByString:@" "] mutableCopy];
    [lineComponents removeObject:@""]; //Remove empty strings from the line which exist for some reason
    if ([debLine characterAtIndex:0] == '#') return NULL;
    
    if ([lineComponents count] >= 3) {
        NSString *archiveType = lineComponents[0];
        NSString *repositoryURL = lineComponents[1];
        NSString *distribution = lineComponents[2];
        
        //Group all of the components into the components array
        NSMutableArray *sourceComponents = [NSMutableArray new];
        for (int i = 3; i < [lineComponents count]; i++) {
            NSString *component = lineComponents[i];
            if (component)  {
                [sourceComponents addObject:component];
            }
        }
        
        ZBBaseRepo *repo = [self initWithArchiveType:archiveType repositoryURL:repositoryURL distribution:distribution components:(NSArray *)sourceComponents];
        repo.debLine = debLine;
        
        return repo;
    }
    
    return [super init];
}

@end

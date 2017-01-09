//
//  Photo.m
//  CameraAndCloud
//
//  Created by Andy Wu on 1/4/17.
//  Copyright © 2017 Andy Wu. All rights reserved.
//

#import "Photo.h"

@implementation Photo

- (instancetype) initWithPhoto:(NSString *)url andLikes:(int)likes andComments:(NSMutableArray *)comment andUUID: (NSString*) uid{
    
    self = [super init];
    if (self) {
        self.imgURL = url;
        self.numLikes = likes;
        self.comments = comment;
        self.uuid = uid;
    }
    return self;
}


@end

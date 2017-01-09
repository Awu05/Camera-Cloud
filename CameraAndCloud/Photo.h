//
//  Photo.h
//  CameraAndCloud
//
//  Created by Andy Wu on 1/4/17.
//  Copyright © 2017 Andy Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject

@property (nonatomic, retain) NSString *imgURL;

@property int numLikes;

@property (nonatomic, retain) NSString *uuid;

@property (nonatomic, retain) NSMutableArray *comments;

- (instancetype)initWithPhoto: (NSString*) url
                     andLikes: (int) likes
                  andComments: (NSMutableArray*) comment
                      andUUID: (NSString*) uid;

@end

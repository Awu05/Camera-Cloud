//
//  DataAccessObject.h
//  CameraAndCloud
//
//  Created by Andy Wu on 1/4/17.
//  Copyright © 2017 Andy Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"
#import "UIImageView+AFNetworking.h"
#import "AFURLSessionManager.h"
#import "AFHTTPSessionManager.h"
@import Firebase;



@interface DataAccessObject : NSObject

+ (id)sharedManager;

@property (nonatomic, retain) NSMutableArray *photos;

- (void) loadImages;

- (void) saveImg: (Photo *) photo;

- (void) uploadImage: (NSString *)imagePath;

- (void) uploadPhoto: (Photo*) photo;

- (void) updatePhoto: (Photo*) photo;

- (void) deletePhoto: (Photo*) photo;



@end

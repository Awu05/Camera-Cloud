//
//  DataAccessObject.m
//  CameraAndCloud
//
//  Created by Andy Wu on 1/4/17.
//  Copyright © 2017 Andy Wu. All rights reserved.
//

#import "DataAccessObject.h"

@implementation DataAccessObject

+ (id)sharedManager {
    static DataAccessObject *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.photos = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) loadImages {
    
    FIRUser *user = [FIRAuth auth].currentUser;
    NSString *email = user.email;
    
    NSArray *editedEmail = [email componentsSeparatedByString:@"@"];
    
    NSString *URLString = [NSString stringWithFormat:@"https://cameraandcloud-c8c42.firebaseio.com/%@/photos.json",editedEmail[0]];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", nil];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        for (NSString *properties in responseObject) {
            NSDictionary *photoDictionary = [responseObject objectForKey:properties];
            NSLog(@"CHECK THESE VSALUESSSS %@", photoDictionary);
            NSLog(@"WHAT IS THIS IDENTIFIER %@", properties);
            int numLikes = [photoDictionary[@"Likes"] intValue];
            NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:photoDictionary[@"Comments"]];
            Photo *newPhoto = [[Photo alloc] initWithPhoto:photoDictionary[@"DownloadURL"] andLikes: numLikes andComments:newArray andUUID:properties];
            [self.photos addObject:newPhoto];
            //[self updatePhoto:newPhoto];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadComplete" object:nil];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

- (void) saveImg: (Photo *) photo {
    [self.photos addObject:photo];
    
    NSLog(@"Uploading Photo Object\n");
    [self uploadPhoto:photo];
}


- (void) uploadImage: (NSString *)imagePath {
    
    // Get a reference to the storage service using the default Firebase App
    FIRStorage *storage = [FIRStorage storage];
    
    // Create a storage reference from our storage service
    FIRStorageReference *storageRef = [storage referenceForURL:@"gs://cameraandcloud-c8c42.appspot.com"];
    
    NSURL *localFile = [NSURL fileURLWithPath:imagePath];
    
    //Create a UUID (Universial Unique Identifier) for each file name
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    NSString *imgPath = [NSString stringWithFormat:@"Images/%@.jpg", uuid];
    
    FIRStorageReference *photoRef = [storageRef child:imgPath];
    
    //---------- METADATA --------------------
    
    // Create file metadata including the content type
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    metadata.contentType = @"image/jpeg";
    
    FIRStorageUploadTask *uploadTask = [photoRef putFile:localFile metadata:metadata completion:^(FIRStorageMetadata *metadata, NSError *error) {
        if(error != nil) {
            NSLog(@"There was an error!\n");
        }
        else {
            //NSLog(@"Upload Finished!\n");
            NSURL *downloadURL = metadata.downloadURL;
            //NSLog(@"DL URL: %@\n", downloadURL);
            
            NSMutableArray *comments = [[NSMutableArray alloc] init];
            Photo *picture = [[Photo alloc] initWithPhoto:downloadURL.absoluteString andLikes:0 andComments:comments andUUID:uuid];
            [self saveImg:picture];
        }
    }];
    
    [uploadTask resume];
    
    
}
- (void) uploadPhoto: (Photo*) photo {
    FIRUser *user = [FIRAuth auth].currentUser;
    NSString *email = user.email;
    
    NSArray *editedEmail = [email componentsSeparatedByString:@"@"];
    
    NSString *URLString = [NSString stringWithFormat:@"https://cameraandcloud-c8c42.firebaseio.com/%@/photos.json",editedEmail[0]];
    
    NSDictionary *parameters = @{@"DownloadURL":photo.imgURL, @"Likes":@0, @"Comments":@[], @"UUID":photo.uuid};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
     
     [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSLog(@"success!");
         
         NSLog(@"Response Object: %@\n", responseObject);
         
         Photo *modifyLast = [self.photos lastObject];
         NSString *modUUID = [NSString stringWithFormat:@"%@", responseObject];
         NSArray *newUUID = [modUUID componentsSeparatedByString:@"\""];
         modUUID = newUUID[1];
         NSArray *newUUID2 = [modUUID componentsSeparatedByString:@"\""];
         modifyLast.uuid = newUUID2[0];
         NSLog(@"UUID: %@ //", modifyLast.uuid);
         [self updatePhoto:modifyLast];
         
         
         
         
         [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadComplete" object:nil];
         
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
    }];
    
}

- (void) updatePhoto: (Photo*) photo {
    FIRUser *user = [FIRAuth auth].currentUser;
    NSString *email = user.email;
    
    NSArray *editedEmail = [email componentsSeparatedByString:@"@"];
    
    NSString *URLString = [NSString stringWithFormat:@"https://cameraandcloud-c8c42.firebaseio.com/%@/photos/%@.json",editedEmail[0], photo.uuid];
    
    NSDictionary *parameters = @{@"DownloadURL":photo.imgURL, @"Likes": [NSNumber numberWithInt:photo.numLikes], @"Comments":photo.comments, @"UUID":photo.uuid};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager PATCH:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success!");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
    }];
}

- (void) deletePhoto:(Photo *)photo {
    
    FIRUser *user = [FIRAuth auth].currentUser;
    NSString *email = user.email;
    
    NSArray *editedEmail = [email componentsSeparatedByString:@"@"];
    
    NSString *URLString = [NSString stringWithFormat:@"https://cameraandcloud-c8c42.firebaseio.com/%@/photos/%@.json",editedEmail[0], photo.uuid];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setStringEncoding:NSUTF8StringEncoding];
    
    manager.requestSerializer=serializer;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager DELETE:URLString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"You Have Successfully deleted the photo!");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"You Have Failed to delete the photo!");
    }];
    
    [self.photos removeObject:photo];
    
    
}

@end

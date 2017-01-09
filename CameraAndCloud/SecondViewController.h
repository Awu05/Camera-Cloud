//
//  SecondViewController.h
//  CameraAndCloud
//
//  Created by Andy Wu on 12/20/16.
//  Copyright © 2016 Andy Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataAccessObject.h"
@import FirebaseDatabase;
@import Firebase;
@import FirebaseStorage;




@interface SecondViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, retain) UIImagePickerController *imagePickerController;

@property (nonatomic, retain) DataAccessObject *mySharedData;

- (IBAction)takeAPhoto:(id)sender;
- (IBAction)takeAPhotoBottomBtn:(id)sender;

- (IBAction)uploadAPhoto:(id)sender;
- (IBAction)uploadAPhotoBottomBtn:(id)sender;



@end


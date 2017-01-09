//
//  SecondViewController.m
//  CameraAndCloud
//
//  Created by Andy Wu on 12/20/16.
//  Copyright © 2016 Andy Wu. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.mySharedData = [DataAccessObject sharedManager];
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showPhotos {
    self.imagePickerController = [[UIImagePickerController alloc]init];
    self.imagePickerController.delegate = self;
    [self.imagePickerController setAllowsEditing:true];
    self.imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    NSLog(@"Uploading Photo to Firebase.\n");
    
    //Now, save the image to your apps temp folder,
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"upload-image.tmp"];
    
    NSLog(@"PATH: %@\n", path);
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:path atomically:YES];
    
    [self.mySharedData uploadImage:path];
    
    [self.imagePickerController dismissViewControllerAnimated:YES completion:^{
        [self finishedUploading];
    }];

}

- (void) finishedUploading {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Successful!"
                                  message:@"You have uploaded the image successfully!"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) takePicture {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self noCamera];
        });
        
    }
    else {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        self.imagePickerController = picker;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
        //[self showPhotos];
    }
    
    
}

- (void) noCamera {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Error!"
                                  message:@"Your device does not have a camera!"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)takeAPhoto:(id)sender {
    NSLog(@"Take a photo\n");
    [self takePicture];
    
}

- (IBAction)takeAPhotoBottomBtn:(id)sender {
    NSLog(@"Take a photo\n");
    [self takePicture];
    
}

- (IBAction)uploadAPhoto:(id)sender {
    NSLog(@"Upload a photo\n");
    [self showPhotos];
}

- (IBAction)uploadAPhotoBottomBtn:(id)sender {
    NSLog(@"Upload a photo\n");
    [self showPhotos];
}

@end

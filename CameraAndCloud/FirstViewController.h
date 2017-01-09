//
//  FirstViewController.h
//  CameraAndCloud
//
//  Created by Andy Wu on 12/20/16.
//  Copyright © 2016 Andy Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataAccessObject.h"
#import "AWCollectionViewCell.h"
#import "ViewPhotoViewController.h"
@import FirebaseDatabase;
@import Firebase;
@import FirebaseStorage;
@import FirebaseAuth;


@interface FirstViewController : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (nonatomic, retain) DataAccessObject *mySharedData;

@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *password;

- (IBAction)signoutBtn:(id)sender;


@end


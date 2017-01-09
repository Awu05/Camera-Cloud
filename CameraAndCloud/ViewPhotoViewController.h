//
//  ViewPhotoViewController.h
//  CameraAndCloud
//
//  Created by Andy Wu on 1/5/17.
//  Copyright © 2017 Andy Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"
#import "DataAccessObject.h"
@import Firebase;

@interface ViewPhotoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *numLikes;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, retain) DataAccessObject *mySharedData;

@property (nonatomic, retain) Photo *photo;

@property (nonatomic, retain) UIImage *img;

@property (weak, nonatomic) IBOutlet UITextField *replyText;

@property (weak, nonatomic) IBOutlet UIView *commentView;

- (IBAction)likeBtn:(id)sender;

- (IBAction)moreActions:(id)sender;

- (IBAction)replyBtn:(id)sender;

- (IBAction)sendBtn:(id)sender;

@end

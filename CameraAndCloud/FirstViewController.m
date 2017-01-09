//
//  FirstViewController.m
//  CameraAndCloud
//
//  Created by Andy Wu on 12/20/16.
//  Copyright © 2016 Andy Wu. All rights reserved.
//

#import "FirstViewController.h"
#import "UIImageView+AFNetworking.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    /*
    self.ref = [[FIRDatabase database] reference];
    FIRUser *user = [FIRAuth auth].currentUser;
    NSString *email = user.email;
    
    [[[self.ref child:email] child:@"photos"]
     setValue:@{@"downloadURL": @"www.no.com"}];
    */
    
    self.mySharedData = [DataAccessObject sharedManager];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCollection:) name:@"downloadComplete" object:nil];
    
    static NSString* const hasRunAppOnceKey = @"hasRunAppOnceKey";
    if ([defaults boolForKey:hasRunAppOnceKey] == NO)
    {
        // Some code you want to run on first use...
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self createAccount];
        });
        
        [defaults setBool:YES forKey:hasRunAppOnceKey];
    }
    else {
        NSLog(@"Trying to load from defaults\n");
        NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
        NSString *pass = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
        //NSLog(@"Username: %@\nPass: %@\n", username, pass);
        self.email = username;
        self.password = pass;
        
        
        if(username == nil || pass == nil) {
            NSLog(@"No defaults founds!\n");
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self login];
            });
        }
        else {
            
            [[FIRAuth auth] signInWithEmail:self.email password:self.password
                                 completion:^(FIRUser *user, NSError *error) {
                                     if(error){
                                         NSLog(@"There was an error logging into your account!\n");
                                         dispatch_async(dispatch_get_main_queue(), ^ {
                                             [self login];
                                         });
                                     }
                                     else {
                                         NSLog(@"You have successfully logged into your account!\n");
                                         [self saveLoginInfo];
                                         [self.mySharedData loadImages];
                                         
                                     }
                                 }];
        }
        
    }
    
}

- (void) viewWillAppear:(BOOL)animated {
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) reloadCollection: (NSNotification *)note {
    NSLog(@"Received Notification - Showing the images");
    [self.collectionView reloadData];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.mySharedData.photos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"AWCollectionViewCell" bundle:nil]   forCellWithReuseIdentifier: @"FbCell"];
    
    static NSString *cellIdentifier = @"FbCell";
    Photo *currentPhoto = self.mySharedData.photos[indexPath.row];
    AWCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSURL *nsurl=[NSURL URLWithString:currentPhoto.imgURL];
    
    [cell.imgView setImageWithURLRequest:[NSURLRequest requestWithURL:nsurl] placeholderImage:[UIImage imageNamed:@"photo_01.jpg"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        NSLog(@"Successfully Downloaded Image.\n");
        cell.imgView.image = image;
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        NSLog(@"Failed to download image.\n");
    }];
    
    return cell;
}

//Sets the size of the cell
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    float height = [[UIScreen mainScreen] bounds].size.height;
    
    float width = [[UIScreen mainScreen] bounds].size.width;
    
    return CGSizeMake(width * 0.22, height * 0.10);
}


- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    AWCollectionViewCell *currentCell = (AWCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    ViewPhotoViewController *viewPhotoVC = [[ViewPhotoViewController alloc] init];
    viewPhotoVC.photo = self.mySharedData.photos[indexPath.row];
    
    viewPhotoVC.img = currentCell.imgView.image;
    [self.navigationController pushViewController:viewPhotoVC animated:YES];
}

- (void) createAccount {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Create Your Account"
                                  message:@"Enter Your Credentials Or Press Cancel To Log In"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   //Do Some action here
                                                   
                                                   NSString *user = ((UITextField *)[alert.textFields objectAtIndex:0]).text;
                                                   self.email = user;
                                                   
                                                   NSString *pass = ((UITextField *)[alert.textFields objectAtIndex:1]).text;
                                                   self.password = pass;
                                                   
                                                   [[FIRAuth auth]
                                                    createUserWithEmail:self.email
                                                    password:self.password
                                                    completion:^(FIRUser *_Nullable user,
                                                                 NSError *_Nullable error) {
                                                        if(error){
                                                            NSLog(@"There was an error creating your account!\n");
                                                        }
                                                        else {
                                                            NSLog(@"Your accout was created successfully!\n");
                                                            [self saveLoginInfo];
                                                        }
                                                    }];
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self login];
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Username";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) login {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Log In"
                                  message:@"Enter Your Credentials"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   //Do Some action here
                                                   
                                                   NSString *user = ((UITextField *)[alert.textFields objectAtIndex:0]).text;
                                                   self.email = user;
                                                   
                                                   NSString *pass = ((UITextField *)[alert.textFields objectAtIndex:1]).text;
                                                   self.password = pass;
                                                   
                                                   [[FIRAuth auth] signInWithEmail:self.email password:self.password
                                                        completion:^(FIRUser *user, NSError *error) {
                                                                            if(error){
                                                                                NSLog(@"There was an error logging into your account!\n");
                                                                                [self login];
                                                                            }
                                                                            else {
                                                                                NSLog(@"You have successfully logged into your account!\n");
                                                                                [self signinAlert];
                                                                                [self saveLoginInfo];
                                                                                [self.mySharedData loadImages];
                                                                            }
                                                                        }];
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Username";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
    }];
    
    
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) saveLoginInfo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.email forKey:@"email"];
    [defaults setValue:self.password forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (IBAction)signoutBtn:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@"" forKey:@"email"];
    [defaults setValue:@"" forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.mySharedData.photos removeAllObjects];
    [self.collectionView reloadData];
    [self signoutAlert];
}

- (void) signoutAlert {
    NSString *title = NSLocalizedString(@"You Have Signed Out!", nil);
    NSString *message = NSLocalizedString(@"", nil);
    NSString *okButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // Create the actions.
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Signed Out!");
        [self.collectionView reloadData];
        [self createAccount];
    }];
    
    // Add the actions.
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) signinAlert {
    NSString *title = NSLocalizedString(@"Successfully Logged In!", nil);
    NSString *message = NSLocalizedString(@"", nil);
    NSString *okButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // Create the actions.
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Signed In!");
    }];
    
    // Add the actions.
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end

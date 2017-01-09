//
//  ViewPhotoViewController.m
//  CameraAndCloud
//
//  Created by Andy Wu on 1/5/17.
//  Copyright © 2017 Andy Wu. All rights reserved.
//

#import "ViewPhotoViewController.h"
#import "PhotoTableViewCell.h"
#import "Photo.h"

@interface ViewPhotoViewController ()

@end

@implementation ViewPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 140;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UINib *cellNib = [UINib nibWithNibName:@"PhotoTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"Cell"];
    
    self.imgView.image = self.img;
    
    self.numLikes.enabled = NO;
    
    self.mySharedData = [DataAccessObject sharedManager];
    
    self.numLikes.title = [NSString stringWithFormat:@"%d Likes", self.photo.numLikes];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Incomplete method implementation.
    // Return the number of sections.
    return [self.photo.comments count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    PhotoTableViewCell *cell = (PhotoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    FIRUser *user = [FIRAuth auth].currentUser;
    NSString *email = user.email;
    
    NSArray *editedEmail = [email componentsSeparatedByString:@"@"];
    
    cell.userLabel.text = editedEmail[0];
    
    
    cell.textLabel.text = self.photo.comments[indexPath.section];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10; // you can have your own choice, of course
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (IBAction)likeBtn:(id)sender {
    self.photo.numLikes++;
    self.numLikes.title = [NSString stringWithFormat:@"%d Likes", self.photo.numLikes];
    [self.mySharedData updatePhoto:self.photo];
}

- (IBAction)moreActions:(id)sender {
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *deleteButtonTitle = NSLocalizedString(@"Delete Photo", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"You pressed Cancel!\n");
    }];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:deleteButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"You pressed Delete Photo!\n");
        [self.mySharedData deletePhoto:self.photo];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)replyBtn:(id)sender {
    if(self.commentView.hidden) {
        self.commentView.hidden = false;
    }
    else {
        self.commentView.hidden = true;
    }
}

- (IBAction)sendBtn:(id)sender {
    NSLog(@"Comment: %@", self.replyText.text);
    [self.photo.comments addObject:self.replyText.text];
    [self.mySharedData updatePhoto:self.photo];
    [self.replyText resignFirstResponder];
    self.replyText.text = @"";
    [self fixTableView];
    self.commentView.hidden = true;
    [self.tableView reloadData];
}

- (void) fixTableView {
//    UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
//    self.tableView.contentInset = adjustForTabbarInsets;
//    self.tableView.scrollIndicatorInsets = adjustForTabbarInsets;
    CGFloat bottom =  self.tabBarController.tabBar.frame.size.height;
    NSLog(@"%f",bottom);
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, bottom, 0)];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, bottom, 0);
}

-(void)keyboardWillShow {
    // Animate the current view out of the way
    [UIView animateWithDuration:0.3f animations:^ {
        self.replyText.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moveTextField:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
    }];
}

- (void) moveTextField: (NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    double commentTextStart = self.view.frame.size.height - keyboardFrameBeginRect.size.height - self.commentView.frame.size.height;
    self.commentView.frame = CGRectMake(0, commentTextStart, self.commentView.frame.size.width, self.commentView.frame.size.height);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"Comment: %@", self.replyText.text);
    [self.photo.comments addObject:self.replyText.text];
    [self.mySharedData updatePhoto:self.photo];
    [self.replyText resignFirstResponder];
    self.replyText.text = @"";
    [self fixTableView];
    self.commentView.hidden = true;
    [self.tableView reloadData];
    
    return YES;
}

-(void)keyboardWillHide {
    // Animate the current view back to its original position
    [UIView animateWithDuration:0.3f animations:^ {
        self.commentView.frame = CGRectMake(0, 0, self.commentView.frame.size.width, self.commentView.frame.size.height);
    }];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self fixTableView];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

@end

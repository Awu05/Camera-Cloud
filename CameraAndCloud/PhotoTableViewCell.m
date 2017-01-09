//
//  PhotoTableViewCell.m
//  CameraAndCloud
//
//  Created by Andy Wu on 1/5/17.
//  Copyright © 2017 Andy Wu. All rights reserved.
//

#import "PhotoTableViewCell.h"

@implementation PhotoTableViewCell

//@dynamic textLabel;
@synthesize textLabel = _textLabel;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
//    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
//    
//    [lbl setText:@"Testo di prova..."];
//    [lbl setBackgroundColor:[UIColor clearColor]];
//    [[self view] addSubview:lbl];
//    [lbl sizeToFit];
    
//    CALayer* layer = [self.textLabel layer];
//    
//    CALayer *bottomBorder = [CALayer layer];
//    bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
//    bottomBorder.borderWidth = 1;
//    bottomBorder.frame = CGRectMake(-1, self.textLabel.frame.size.height+5, self.textLabel.frame.size.width, 1);
//    [bottomBorder setBorderColor:[UIColor blackColor].CGColor];
//    [layer addSublayer:bottomBorder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

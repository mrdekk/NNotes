//
//  NotesListCell.h
//  NNotes
//
//  Created by Olga Vyrostko on 20.07.16.
//  Copyright © 2016 Ольга Выростко. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotesListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *noteCellTitle;
@property (weak, nonatomic) IBOutlet UILabel *noteCellDescription;
@property (nonatomic, strong) NSString * noteCellId;

@end

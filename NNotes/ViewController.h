//
//  ViewController.h
//  NNotes
//
//  Created by Ольга Выростко on 12.06.16.
//  Copyright © 2016 Ольга Выростко. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "NotesDataController.h"
#import "NotesTableViewController.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) NSIndexPath * index;
@property (nonatomic, strong) NotesDataController * dataCtrl;
@property (nonatomic, weak) NotesTableViewController * parent;

@end


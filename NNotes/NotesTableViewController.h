//
//  NotesTableViewController.h
//  NNotes
//
//  Created by Ольга Выростко on 12.06.16.
//  Copyright © 2016 Ольга Выростко. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NotesDataController.h"
#import "Note.h"
#import "NotesService.h"

@interface NotesTableViewController : UITableViewController

@property (nonatomic, strong) NotesDataController * dataCtrl;
@property (nonatomic, strong) NotesService * notesService;
@property (nonatomic, assign) BOOL needUpdateAll;
@property (nonatomic, strong) NSMutableArray * cellsToUpdate;

@end

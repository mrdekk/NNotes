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

@interface ViewController : UIViewController

@property (nonatomic) NSInteger index;
@property (nonatomic, retain) NotesDataController * dataCtrl;

@end


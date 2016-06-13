//
//  NotesDataController.h
//  NNotes
//
//  Created by Ольга Выростко on 12.06.16.
//  Copyright © 2016 Ольга Выростко. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Note.h"
#import "DbNote+CoreDataProperties.h"

@interface NotesDataController : NSObject

@property (strong) NSManagedObjectContext *managedObjectContext;

- (void) initializeCoreData;
- (void) addNote: (Note *) note;
- (void) updateNoteAtIndex: (NSInteger) index WithNote: (Note *) note;
- (NSInteger) countNotes;
- (Note *) selectNoteByIndex: (NSInteger) index;
- (NSMutableArray *) selectNotes;

@end

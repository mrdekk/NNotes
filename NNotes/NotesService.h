//
//  NotesService.h
//  NNotes
//
//  Created by Olga Vyrostko on 25.07.16.
//  Copyright © 2016 Ольга Выростко. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Note.h"

@protocol NotesDisplayer <NSObject>

-(void) notifyThatNotesAreSentSuccessfully: (BOOL) success;
-(void) notifyThatNotesWereNotLoaded;
-(void) addNotesToList: (NSArray *) loadedNotes;
-(void) updateNote: (Note *) note withId: (NSString *) noteId;

@end

@interface NotesService : NSObject

@property (nonatomic, weak) id<NotesDisplayer> notesDisplayerDelegate;

-(void) sendNotesToServer: (NSArray *) notes;
-(void) loadNotesFromServer;

@end

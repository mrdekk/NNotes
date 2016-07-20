//
//  Note.m
//  NNotes
//
//  Created by Ольга Выростко on 12.06.16.
//  Copyright © 2016 Ольга Выростко. All rights reserved.
//

#import "Note.h"

@implementation Note

-(id) initNoteWithDbNote:(DbNote *) dbNote {
    self = [super init];
    if (self) {
        self.title = dbNote.title;
        self.text = dbNote.text;
        self.colorR = dbNote.colorR;
        self.colorB = dbNote.colorB;
        self.colorG = dbNote.colorG;
        self.noteId = dbNote.noteId;
        self.rowId = dbNote.rowId;
    }
    
    return self;
}

-(DbNote *) createDbNote {
    DbNote * dbNote = [[DbNote alloc] init];
    if (dbNote) {
        dbNote.title = self.title;
        dbNote.text = self.text;
        dbNote.colorR = self.colorR;
        dbNote.colorB = self.colorB;
        dbNote.colorG = self.colorG;
        dbNote.noteId = self.noteId;
        dbNote.rowId = self.rowId;
    }
    
    return dbNote;
}

@end

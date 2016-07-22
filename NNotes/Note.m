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
    }
    
    return dbNote;
}

-(NSString *) description {
    return [NSString stringWithFormat: @"noteId=%@", self.noteId];
}

-(id)copyWithZone:(NSZone *)zone
{
    Note * note = [[Note alloc] init];
    note.noteId = [self.noteId copyWithZone: zone];
    note.colorR = [self.colorR copyWithZone: zone];
    note.colorB = [self.colorB copyWithZone: zone];
    note.colorG = [self.colorG copyWithZone: zone];
    note.title = [self.title copyWithZone: zone];
    note.text = [self.text copyWithZone: zone];
    
    return note;
}

@end

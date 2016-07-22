//
//  NotesDataController.m
//  NNotes
//
//  Created by Ольга Выростко on 12.06.16.
//  Copyright © 2016 Ольга Выростко. All rights reserved.
//

#import "NotesDataController.h"

@implementation NotesDataController

- (id)init
{
    self = [super init];
    if (!self)
        return nil;
    
    // Производим необходимые приготовления к работе с БД
    // при помощи CoreData
    [self initializeCoreData];
    
    return self;
}

- (void)initializeCoreData
{
    // Инициализация Managed Object Model
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DbNotesModel" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(mom != nil, @"Ошибка инициализации Managed Object Model");
    
    // Инициализация PSC
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:psc];
    [self setManagedObjectContext:moc];
    
    // Проверяем, что существует Notes.sqlite, если нет, создаем
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"Notes.sqlite"];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSError *error = nil;
        NSPersistentStoreCoordinator *psc = [[self managedObjectContext] persistentStoreCoordinator];
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options: [[NSDictionary alloc] init] error:&error];
        NSAssert(store != nil, @"Ошибка инициализации PSC: %@\n%@", [error localizedDescription], [error userInfo]);
    });
}

-(void) addNote:(Note *)note {
    // Создаем новую заметку в БД, заполняем введенными пользователем данными
    DbNote * crnote = [NSEntityDescription insertNewObjectForEntityForName:@"DbNote" inManagedObjectContext:[self managedObjectContext]];
    
    crnote.text = note.text;
    crnote.title = note.title;
    crnote.colorR = note.colorR;
    crnote.colorG = note.colorG;
    crnote.colorB = note.colorB;
    crnote.rowId = [NSNumber numberWithLong: [self countNotes] - 1];
    crnote.noteId = [[[crnote objectID] URIRepresentation] absoluteString];
    
    NSError *error = nil;
    if ([[self managedObjectContext] save:&error] == NO) {
        NSAssert(NO, @"Не удалось сохранить заметку: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

-(Note *) selectNoteById: (NSString *) noteId {
    DbNote * dbNote = [self selectDbNoteById: noteId];
    if (!dbNote)
        return nil;
    
    return [[Note alloc] initNoteWithDbNote: dbNote];
}

-(Note *) selectNoteByIndex:(NSInteger)index {
    DbNote * dbNote = [self selectDbNoteByRow: [NSNumber numberWithLong: index]];
    if (!dbNote)
        return nil;
    
    return [[Note alloc] initNoteWithDbNote: dbNote];
}

-(DbNote *) selectDbNoteById: (NSString *) noteId {
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"DbNote" inManagedObjectContext: self.managedObjectContext]];
    NSPredicate * predicate = [NSPredicate predicateWithFormat: @"noteId = %@", noteId ];
    [request setPredicate: predicate];
    
    NSError *error = nil;
    NSArray * results = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (!results || [ results count ] == 0 ) {
        NSLog(@"Нет данных о заметке: %@\n%@", [error localizedDescription], [error userInfo]);
        return nil;
    }
    return [results objectAtIndex: 0];
}

-(DbNote *) selectDbNoteByRow: (NSNumber *) row {
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"DbNote" inManagedObjectContext: self.managedObjectContext]];
    NSPredicate * predicate = [NSPredicate predicateWithFormat: @"rowId = %@", row ];
    [request setPredicate: predicate];
    
    NSError *error = nil;
    NSArray * results = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (!results || [ results count ] == 0 ) {
        NSLog(@"Нет данных о заметке: %@\n%@", [error localizedDescription], [error userInfo]);
        return nil;
    }
    return [results objectAtIndex: 0];
}

-(void) updateNote: (Note *) note {
    DbNote * dbNote = [self selectDbNoteById: note.noteId];
    dbNote.title = note.title;
    dbNote.text = note.text;
    dbNote.noteId = note.noteId;
    dbNote.rowId = note.rowId;
    dbNote.colorR = note.colorR;
    dbNote.colorB = note.colorB;
    dbNote.colorG = note.colorG;
    
    NSError * error = nil;
    if ([[self managedObjectContext] save:&error] == NO) {
        NSAssert(NO, @"Не удалось сохранить заметку: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

- (void) updateNoteAtIndex: (NSInteger) index WithNote: (Note *) note {
    DbNote * selected = [self selectDbNoteByRow: [NSNumber numberWithLong: index]];
    selected.title = note.title;
    selected.text = note.text;
    selected.colorR = note.colorR;
    selected.colorG = note.colorG;
    selected.colorB = note.colorB;
    selected.rowId = [NSNumber numberWithLong: index];
    
    NSError * error = nil;
    if ([[self managedObjectContext] save:&error] == NO) {
        NSAssert(NO, @"Не удалось сохранить заметку: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

- (NSMutableArray *) selectNotes {
    // Запрашиваем список (полный) заметок
    NSMutableArray * notes = [[NSMutableArray alloc] init];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DbNote"];
    NSError *error = nil;
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (!results) {
        // Не удалось получить список заметок, возвращаем пустой список
        NSLog(@"Не удалось получить список заметок: %@\n%@", [error localizedDescription], [error userInfo]);
        return notes;
    }
    
    // Преобразуем заметки уровня модели БД в заметки Web-модели
    for ( DbNote * obj in results) {
        Note * note = [[Note alloc] initNoteWithDbNote: obj];
        [notes addObject: note];
    }
    return notes;
}

- (NSInteger)countNotes {
    // Считаем количество хранимых сообщений
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"DbNote" inManagedObjectContext: self.managedObjectContext]];
    [request setIncludesSubentities:NO];
    
    NSError *err;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        return 0;
    }
    return count;
}

- (void) removeNoteByIndex:(NSInteger)index {
    // Удаляем заметку
    
    // По индексу получаем из БД хранимую заметку
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"DbNote" inManagedObjectContext: self.managedObjectContext]];
    [request setFetchOffset: index ];
    [request setFetchLimit: 1];
    
    NSError *error = nil;
    NSArray * results = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (!results || [ results count ] == 0 ) {
        NSLog(@"Error fetching note: %@\n%@", [error localizedDescription], [error userInfo]);
        return;
    }
    
    // В БД есть нужная заметка, удаляем ее
    DbNote * selected = (DbNote *) [results objectAtIndex: 0];
    [self.managedObjectContext deleteObject: selected];
    if ([[self managedObjectContext] save:&error] == NO) {
        NSAssert(NO, @"Не удалось удалить заметку: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

-(void) moveNoteWithId: (NSString *) noteId toPlace: (NSNumber *) row {
    DbNote * toMoveNote = [self selectDbNoteById: noteId];
    DbNote * toReplaceNote = [self selectDbNoteByRow: row];
    
    NSNumber * fromRow = toMoveNote.rowId;
    toMoveNote.rowId = row;
    toReplaceNote.rowId = fromRow;
    
    NSError * error = nil;
    if ([[self managedObjectContext] save:&error] == NO) {
        NSAssert(NO, @"Не удалось сохранить заметку: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

@end


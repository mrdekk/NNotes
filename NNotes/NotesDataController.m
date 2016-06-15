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
    
    NSError *error = nil;
    if ([[self managedObjectContext] save:&error] == NO) {
        NSAssert(NO, @"Не удалось сохранить заметку: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    
}

- (void) updateNoteAtIndex: (NSInteger) index WithNote: (Note *) note {
    // Обновляем данные уже существующей заметки
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"DbNote" inManagedObjectContext: self.managedObjectContext]];
    [request setFetchOffset: index ];
    [request setFetchLimit: 1];
    
    NSError *error = nil;
    NSArray * results = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (!results || [ results count ] == 0 ) {
        NSLog(@"Нет данных о заметке: %@\n%@", [error localizedDescription], [error userInfo]);
        return;
    }
    
    DbNote * selected = (DbNote *) [results objectAtIndex: 0];
    selected.title = note.title;
    selected.text = note.text;
    selected.colorR = note.colorR;
    selected.colorG = note.colorG;
    selected.colorB = note.colorB;
    
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
        [notes addObject: [[Note alloc] initWithTitle: obj.title Text: obj.text ColorR: obj.colorR ColorG: obj.colorG andColorB: obj.colorB]];
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

- (Note *) selectNoteByIndex: (NSInteger) index {
    // По индексу получаем из БД хранимую заметку
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"DbNote" inManagedObjectContext: self.managedObjectContext]];
    [request setFetchOffset: index ];
    [request setFetchLimit: 1];
    
    NSError *error = nil;
    NSArray * results = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (!results || [ results count ] == 0 ) {
        NSLog(@"Error fetching note: %@\n%@", [error localizedDescription], [error userInfo]);
        return nil;
    }
    
    // Преобразуем заметку уровня модели БД в заметку уровня Web-модели
    Note * note = [[Note alloc] init];
    DbNote * selected = (DbNote *) [results objectAtIndex: 0];
    note.title = selected.title;
    note.text = selected.text;
    note.colorR = selected.colorR;
    note.colorG = selected.colorG;
    note.colorB = selected.colorB;
    return note;
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

@end


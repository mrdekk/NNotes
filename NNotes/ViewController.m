//
//  ViewController.m
//  NNotes
//
//  Created by Ольга Выростко on 12.06.16.
//  Copyright © 2016 Ольга Выростко. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *noteTitle;
@property (weak, nonatomic) IBOutlet UITextView * text;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // В том случае, если установлен индекс,
    // редактируем уже существующую заметку -> нужно загрузить данные
    if ( -1 != self.index ) {
        Note * note = [self.dataCtrl selectNoteByIndex: self.index];
        self.noteTitle.text = note.title;
        self.text.text = note.text;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)addOrEditNote:(id)sender {
    Note * note = [[Note alloc] initWithTitle: self.noteTitle.text Text: self.text.text andColor: [[NSNumber alloc] initWithInt: 1]];
    
    // Если на экране добавления заметки, вызываем метод создания новой заметки;
    // Если на экране редактирования заметки, вызываем метод обновления существующих данных
    if ( -1 == self.index )
        [self.dataCtrl addNote: note];
    else
        [self.dataCtrl updateNoteAtIndex: self.index WithNote: note];
    
    // И возвращаемся на экран со списком заметок
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController * tableViewController = (ViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"NotesTableViewController"];
    
    [self.navigationController pushViewController:tableViewController animated:YES];
}
- (IBAction)removeNote:(id)sender {
    // Удаление нужно осуществлять, только если вызвано оно с экрана редактирования:
    // в противном случае заметки и так пока нет, ничего делать не надо
    if ( -1 != self.index ) {
        [ self.dataCtrl removeNoteByIndex: self.index ];
    }
    
    // Возвращаемся на экран со списком заметок
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController * tableViewController = (ViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"NotesTableViewController"];
    
    [self.navigationController pushViewController:tableViewController animated:YES];
}

@end

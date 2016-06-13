//
//  NotesTableViewController.m
//  NNotes
//
//  Created by Ольга Выростко on 12.06.16.
//  Copyright © 2016 Ольга Выростко. All rights reserved.
//

#import "NotesTableViewController.h"

@interface NotesTableViewController ()

@end

@implementation NotesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Создаем новый NotesdataCtrl для манипуляций с БД
    self.dataCtrl = [[NotesDataController alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataCtrl countNotes];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotesListCell" forIndexPath:indexPath];
    
    // Запрашиваем следующую по порядку заметку
    Note * note = [self.dataCtrl selectNoteByIndex: indexPath.row ];
    UIColor * clr = [[UIColor alloc] initWithRed: [note.colorR doubleValue] green: [note.colorG doubleValue] blue: [note.colorB doubleValue] alpha: [[[NSNumber alloc] initWithDouble: 1] doubleValue]];
    
    // И конфигурируем ячейку в соответствии с полученными данными
    cell.textLabel.text = note.title;
    cell.backgroundColor = clr;
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath * index = [self.tableView indexPathForCell:sender];
    UIViewController * ctrl = [segue destinationViewController];
    
    if ([ctrl class] == [ViewController class]) {
        ViewController * detailCtrl = (ViewController *) ctrl;
        
        // Устанавливаем контроллеру экрана детального просмотра
        // делегата для работы с БД
        detailCtrl.dataCtrl = self.dataCtrl;
        
        // Если добавление новой заметки, устанавливаем индекс = -1
        // Если просмотр/редактирование существующей, ее индекс
        if ( nil == index ) {
            int i = -1;
            NSInteger nsi = (NSInteger) i;
            detailCtrl.index = nsi;
        }
        else
            detailCtrl.index = index.row;
    }
}

@end

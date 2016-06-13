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
    
    // Конфигурируем ячейку
    [[cell textLabel] setText: [self getNoteTitleForRowAtIndexPath: indexPath]];
    return cell;
}

-(NSString *) getNoteTitleForRowAtIndexPath: (NSIndexPath *) indexPath {
    return [[self.dataCtrl selectNoteByIndex: indexPath.row ] title];
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

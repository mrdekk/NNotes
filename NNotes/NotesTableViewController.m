//
//  NotesTableViewController.m
//  NNotes
//
//  Created by Ольга Выростко on 12.06.16.
//  Copyright © 2016 Ольга Выростко. All rights reserved.
//

#import "NotesTableViewController.h"
#import "ViewController.h"

@interface NotesTableViewController ()

@end

@implementation NotesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Создаем новый NotesdataCtrl для манипуляций с БД
    self.dataCtrl = [[NotesDataController alloc] init];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    if (self.needUpdateAll) {
        [self.tableView reloadData];
        self.needUpdateAll = NO;
    }
    else if ([self.cellsToUpdate count] > 0) {
        [self.tableView reloadRowsAtIndexPaths: self.cellsToUpdate withRowAnimation: UITableViewRowAnimationAutomatic];
        [self.cellsToUpdate removeAllObjects];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Custom Setters and Gettes
-(NSMutableArray *) cellsToUpdate {
    if (nil == _cellsToUpdate)
        _cellsToUpdate = [[NSMutableArray alloc] init];
    
    return _cellsToUpdate;
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
        detailCtrl.parent = self;
        
        // Устанавливаем контроллеру экрана детального просмотра
        // делегата для работы с БД
        detailCtrl.dataCtrl = self.dataCtrl;
        
        // Если добавление новой заметки, устанавливаем индекс = nil
        // Если просмотр/редактирование существующей, ее индекс
        detailCtrl.index = index;
    }
}

@end

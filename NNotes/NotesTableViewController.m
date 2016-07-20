//
//  NotesTableViewController.m
//  NNotes
//
//  Created by Ольга Выростко on 12.06.16.
//  Copyright © 2016 Ольга Выростко. All rights reserved.
//

#import "NotesTableViewController.h"
#import "ViewController.h"
#import "NotesListCell.h"

@interface NotesTableViewController() <UpdatableNotesTable>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *reorderModeButton;

@end

@implementation NotesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Создаем новый NotesdataCtrl для манипуляций с БД
    self.dataCtrl = [[NotesDataController alloc] init];
    
    // Конфигурируем tableView для автоматического определения высоты ячейки
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = [NotesTableViewController estimatedRowHeight];
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

#pragma mark - Constants
+(NSInteger) estimatedRowHeight {
    return 44.0;
}

#pragma mark - Custom Setters and Gettes
-(NSMutableArray *) cellsToUpdate {
    if (nil == _cellsToUpdate)
        _cellsToUpdate = [[NSMutableArray alloc] init];
    
    return _cellsToUpdate;
}

#pragma mark - Methods of protocol UpdatableNotesTable
-(void) markCellAsRequiringUpdate:(NSIndexPath *)pathToCell {
    [self.cellsToUpdate addObject: pathToCell];
}

#pragma mark - Table view data source
- (IBAction)changeToReorderMode:(id)sender {
    if (self.isEditing)
        [self endEditing];
    else
        [self startEditing];
}

-(void) startEditing {
    [self setEditing: YES animated: YES];
    self.reorderModeButton.title = @"Done";
}

-(void) endEditing {
    [self setEditing: NO animated: NO];
    self.reorderModeButton.title = @"Reorder";
}

- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataCtrl countNotes];
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    NotesListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotesListCell" forIndexPath:indexPath];
    
    // Запрашиваем следующую по порядку заметку
    Note * note = [self.dataCtrl selectNoteByIndex: indexPath.row ];
    UIColor * clr = [[UIColor alloc] initWithRed: [note.colorR doubleValue] green: [note.colorG doubleValue] blue: [note.colorB doubleValue] alpha: [[[NSNumber alloc] initWithDouble: 1] doubleValue]];
    
    // И конфигурируем ячейку в соответствии с полученными данными
    cell.noteCellTitle.text = note.title;
    cell.noteCellDescription.text = note.text;
    cell.noteCellId = note.noteId;
    cell.backgroundColor = clr;
    return cell;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    UITableViewRowAction *editButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"✎\nРедактировать" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewController * detailedCtrl = [sb instantiateViewControllerWithIdentifier: @"detailedView" ];
        detailedCtrl.notesListDelegate = weakSelf;
        detailedCtrl.dataCtrl = weakSelf.dataCtrl;
        detailedCtrl.index = indexPath;
        
        NotesListCell * noteListCell = [self.tableView cellForRowAtIndexPath: indexPath];
        detailedCtrl.noteId = noteListCell.noteCellId;
        
        [weakSelf.navigationController pushViewController: detailedCtrl animated: YES];
    }];
    
    editButton.backgroundColor = [UIColor grayColor];
    
    UITableViewRowAction *deleteButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"✕\nУдалить" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [weakSelf.dataCtrl removeNoteByIndex: indexPath.row];
        [weakSelf.tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
    }];
    deleteButton.backgroundColor = [UIColor redColor];
    
    return @[deleteButton, editButton];
}

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
 */

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NotesListCell * noteListCell = [self.tableView cellForRowAtIndexPath: sourceIndexPath];
    [self.dataCtrl moveNoteWithId: noteListCell.noteCellId toPlace: [NSNumber numberWithLong: destinationIndexPath.row]];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.editing)
        return UITableViewCellEditingStyleNone;
    
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath * index = [self.tableView indexPathForCell:sender];
    UIViewController * ctrl = [segue destinationViewController];
    
    if ([ctrl class] == [ViewController class]) {
        ViewController * detailCtrl = (ViewController *) ctrl;
        detailCtrl.notesListDelegate = self;
        
        // Устанавливаем контроллеру экрана детального просмотра
        // делегата для работы с БД
        detailCtrl.dataCtrl = self.dataCtrl;
        
        // Если добавление новой заметки, устанавливаем индекс = nil
        // Если просмотр/редактирование существующей, ее индекс
        detailCtrl.index = index;
        
        NotesListCell * noteListCell = [self.tableView cellForRowAtIndexPath: index];
        detailCtrl.noteId = noteListCell.noteCellId;
    }
}

@end

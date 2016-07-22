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
@property (weak, nonatomic) IBOutlet UILabel *colorMark;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBottomCompact;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBottom;

@end

@implementation ViewController

+(NSInteger) maxNavTitleLength {
    return 10;
}

+(NSString *) defaultNavTitle {
    return @"Новая";
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // В том случае, если установлен индекс,
    // редактируем уже существующую заметку -> нужно загрузить данные
    if ( nil != self.noteId) {
        Note * note = [self.dataCtrl selectNoteById: self.noteId];
        self.noteTitle.text = note.title;
        self.text.text = note.text;
        
        if ( note.title.length > [ViewController maxNavTitleLength])
            self.navigationItem.title = [ NSString stringWithFormat: @"%@...", [ note.title substringToIndex: [ViewController maxNavTitleLength ] ] ];
        else
            self.navigationItem.title = note.title;
        
        UIColor * clr = [[UIColor alloc] initWithRed: [note.colorR doubleValue] green: [note.colorG doubleValue] blue: [note.colorB doubleValue] alpha: [[[NSNumber alloc] initWithDouble: 1] doubleValue]];
        self.colorMark.backgroundColor = clr;
        self.noteTitle.backgroundColor = clr;
    }
    else
        self.navigationItem.title = [ViewController defaultNavTitle];
    
    [ self observeKeyboard ];
}

-(NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    return navigationController.topViewController.supportedInterfaceOrientations;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    CGFloat height = isPortrait ? keyboardFrame.size.height : keyboardFrame.size.width;
    
    self.text.contentInset = UIEdgeInsetsMake(0, 0, height, 0);
    self.text.scrollIndicatorInsets = self.text.contentInset;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:animationDuration animations:^{
        [weakSelf.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.text.contentInset = UIEdgeInsetsZero;
    self.text.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:animationDuration animations:^{
        [weakSelf.view layoutIfNeeded];
    }];
}

- (IBAction)addOrEditNote:(id)sender {
    #if (CGFLOAT_IS_DOUBLE == 1)
        double clrR, clrG, clrB, alpha;
    #else
        float clrR, clrG, clrB, alpha;
    #endif
    
    UIColor * clr = self.noteTitle.backgroundColor;
    [ clr getRed: &clrR green: &clrG blue: &clrB alpha: &alpha];
    
    Note * note = [[Note alloc] init];
    note.title = self.noteTitle.text;
    note.text = self.text.text;
    note.colorG = [NSNumber numberWithDouble: clrG];
    note.colorR = [NSNumber numberWithDouble: clrR];
    note.colorB = [NSNumber numberWithDouble: clrB];
    note.rowId = [NSNumber numberWithLong: self.index.row];
    note.noteId = self.noteId;
    
    // Если на экране добавления заметки, вызываем метод создания новой заметки;
    // Если на экране редактирования заметки, вызываем метод обновления существующих данных
    if ( nil == self.index ) {
        [self.dataCtrl addNote: note];
        [self.notesListDelegate setNeedUpdateAll: YES];
    }
    else {
        [self.dataCtrl updateNoteAtIndex: self.index.row WithNote: note];
        [self.notesListDelegate markCellAsRequiringUpdate: self.index];
    }
    
    // И возвращаемся на экран со списком заметок
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)removeNote:(id)sender {
    // Удаление нужно осуществлять, только если вызвано оно с экрана редактирования:
    // в противном случае заметки и так пока нет, ничего делать не надо
    if ( nil != self.index ) {
        [ self.dataCtrl removeNoteByIndex: self.index.row ];
    }
    
    // Возвращаемся на экран со списком заметок
    [self.notesListDelegate setNeedUpdateAll: YES];
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)changeColor:(id)sender {
    // Устанавливаем новый цвет заметки
    UIButton * button = (UIButton *) sender;
    self.noteTitle.backgroundColor = button.backgroundColor;
    self.colorMark.backgroundColor = button.backgroundColor;
}

@end

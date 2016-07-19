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
@property (weak, nonatomic) IBOutlet UINavigationItem *navTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBottomCompact;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBottom;

@end

@implementation ViewController

+(NSInteger) maxNavTitleLength {
    return 5;
}

+(NSString *) defaultNavTitle {
    return @"Новая";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // В том случае, если установлен индекс,
    // редактируем уже существующую заметку -> нужно загрузить данные
    if ( -1 != self.index ) {
        Note * note = [self.dataCtrl selectNoteByIndex: self.index];
        self.noteTitle.text = note.title;
        self.text.text = note.text;
        
        if ( note.title.length > [ViewController maxNavTitleLength])
            self.navTitle.title = [ NSString stringWithFormat: @"%@...", [ note.title substringToIndex: [ViewController maxNavTitleLength ] ] ];
        else
            self.navTitle.title = note.title;
        
        UIColor * clr = [[UIColor alloc] initWithRed: [note.colorR doubleValue] green: [note.colorG doubleValue] blue: [note.colorB doubleValue] alpha: [[[NSNumber alloc] initWithDouble: 1] doubleValue]];
        self.colorMark.backgroundColor = clr;
        self.noteTitle.backgroundColor = clr;
    }
    else
        self.navTitle.title = [ViewController defaultNavTitle];
    
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
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.text.contentInset = UIEdgeInsetsZero;
    self.text.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
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
    
    Note * note = [[Note alloc] initWithTitle: self.noteTitle.text Text: self.text.text ColorR: [[NSNumber alloc] initWithDouble: clrR ] ColorG: [[NSNumber alloc] initWithDouble: clrG ] andColorB: [[NSNumber alloc] initWithDouble: clrB ] ];
    
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

- (IBAction)changeColor:(id)sender {
    // Устанавливаем новый цвет заметки
    UIButton * button = (UIButton *) sender;
    self.noteTitle.backgroundColor = button.backgroundColor;
    self.colorMark.backgroundColor = button.backgroundColor;
}

@end

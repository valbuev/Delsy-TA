//
//  SettingsView.m
//  Delsy TA
//
//  Created by Valeriy Buev on 24.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "SettingsView.h"
#import "TAListView.h"
#import "AppDelegate.h"
#import "AppSettings+AppSettingsCategory.h"
#import "TA+TACategory.h"
#import "CustomIOS7AlertView.h"
#import "ClientListForNewOrder_View.h"

@interface SettingsView ()

@end

@implementation SettingsView

@synthesize btnUpdateAllPhotos;
@synthesize btnUpdateData;
@synthesize activityIndicatorAllPhotos;
@synthesize activityIndicatorUpdatingData;
@synthesize labelDataLastUpdate;
@synthesize labelTAName;
@synthesize cellRemoveAllHistory;
@synthesize progressViewUpdatingAllPhotos;
@synthesize managedObjectContext = _managedObjectContext;

// Инициализация свойства managedObjectContext из AppDelegate
- (NSManagedObjectContext *)managedObjectContext {
    if(_managedObjectContext != nil){
        return _managedObjectContext;
    }
    
    id appDelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appDelegate managedObjectContext];
    
    return _managedObjectContext;
}

// Инициализация свойства appSettings из managedObjectContext
-(AppSettings *) appSettings{
    if(_appSettings != nil)
        return _appSettings;
    _appSettings = [AppSettings getInstance:self.managedObjectContext];
    return _appSettings;
}

#pragma mark buttons's clicks
// Нажата кнопка обновления Данных,
// создаем updater для клиентов, отдаем ему контекст, записываемся в делегаты и стартуем обновление
- (IBAction)OnBtnUpdateDataClick:(id)sender{
    // Если сейчас идет обновление, то запрещаем действия
    if(isManagedObjectContextUpdating)
        return;
    clientListUpdater = [[BVAClientListUpdater alloc] init];
    clientListUpdater.managedObjectContext = self.managedObjectContext;
    clientListUpdater.delegate = self;
    [clientListUpdater startUpdating];
}

// после обноавления списка клиентов и скидок запускаем обновление каталога
- (void) UpdatePriceList{
    priceUpdater = [[BVAPriceUpdater alloc] init];
    priceUpdater.managedObjectContext = self.managedObjectContext;
    priceUpdater.delegate = self;
    [priceUpdater startUpdating];
}
- (IBAction)OnBtnUpdateAllPhotosClick:(id)sender{
    // Если сейчас идет обновление, то запрещаем действия
    if(isManagedObjectContextUpdating)
        return;
}

#pragma mark init

// Автогенерированная функция
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isManagedObjectContextUpdating = NO;
    [self addObserversForAppSettings];
    [self setLabelsTexts];
}

//
-(void) setLabelsTexts{
    [self updateLabelDataLastUpdate];
    [self updateLabelTAName];
}

// По выходу производим нужные действия, например, зануляем ссылки, или удаляем обсерверов
-(void)dealloc{
    [self removeObserversForAppSettings];
    self.managedObjectContext = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Updating Labels

//Обновляем даты во время первого запуска, по таймеру, или по сообщению обсервера
-(void) updateLabelDataLastUpdate{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        NSDate *date1 = self.appSettings.clientsListLastUpdate;
        NSDate *date2 = self.appSettings.priceLastUpdate;
        NSDate *date;
        //Выбираем самую давнюю дату
        if( [date1 compare:date2] == NSOrderedDescending)
            date = date2;
        else
            date = date1;
        self.labelDataLastUpdate.text =
            [self dateFormaterForLastUpdateLabels:date];
    }];
}

-(NSString *) dateFormaterForLastUpdateLabels: (NSDate *) lastUpdate{
    if(!lastUpdate)
        return @"Никогда не обновлялось";
    NSDate *now = [NSDate date];
    if([now compare:lastUpdate] == NSOrderedAscending )
        return @"Ошибка в дате обновления";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"Обновлено: dd MMM в hh:mm"];
    return [formatter stringFromDate:lastUpdate];
}
// Обновляем текст лейбла с именем текущего ТА
-(void) updateLabelTAName{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        TA *currentTA = (TA *) self.appSettings.currentTA;
        if(!currentTA)
            self.labelTAName.text = @"";
        else{
            self.labelTAName.text = currentTA.name;
        }
    }];
}


#pragma mark - Table view data source

/**********     Все ячейки статичны, поэтому функции кол-ва секций, ячеек в секции, редактирования ячеек и генерирования ячеек не реализуем     *********/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(cell != self.cellRemoveAllHistory){
        ;
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"TAListView"]){
        TAListView *taListView = segue.destinationViewController;
        taListView.managedObjectContext = self.managedObjectContext;
    }
    else if([segue.identifier isEqualToString:@"ClientListForNewOrder"]){
        ClientListForNewOrder_View *clientListView = segue.destinationViewController;
        clientListView.managedObjectContext = self.managedObjectContext;
    }
}

// Отменяем переход на другие view, если требуется
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    // Если сейчас идет обновление, то запрещаем действия
    if(isManagedObjectContextUpdating)
        return NO;
    if(
            ( [identifier isEqualToString:@"ClientListForNewOrder"]
                || [identifier isEqualToString:@"ClientListForWatchHistory"] )
                && !self.appSettings.currentTA
       )
        {
            return NO;
        }
    return YES;
}

#pragma mark - BVAClientListUpdater

-(void)BVAClientListUpdater:(BVAClientListUpdater *)updater didFinishUpdatingWithErrors:(NSArray *)errors{
    if([errors count] > 0){
        [self showCustomIOS7AlertViewWithMessages:errors title:@"В ходе обновления списка клиентов возникли ошибки:"];
    }
    clientListUpdater = nil;
    [self UpdatePriceList];
}

- (void)BVAClientListUpdater:(BVAClientListUpdater *)updater didStopUpdatingWithErrors:(NSArray *)errors{
    [self showCustomIOS7AlertViewWithMessages:errors title:@"Обновление списка клиентов остановлено из-за следующих ошибок:"];
    clientListUpdater = nil;
    [self UpdatePriceList];
}

-(void)BVAClientListUpdaterDidStartUpdating:(BVAClientListUpdater *)updater{
    // Выставляем флаг
    isManagedObjectContextUpdating = YES;
    // запускаем анимацию
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [self.activityIndicatorUpdatingData startAnimating];
        self.labelDataLastUpdate.text = @"Обновляем список клиентов...";
    }];
}

#pragma mark - BVAPriceUpdater

-(void)BVAPriceUpdater:(BVAPriceUpdater *)updater didFinishUpdatingWithErrors:(NSArray *)errors{
    // Выставляем флаг
    isManagedObjectContextUpdating = NO;
    // Посылаем в основной поток, чтобы сразу изменения вступили в силу
    // останавливаем анимацию
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [self.activityIndicatorUpdatingData stopAnimating];
    }];
    if([errors count] > 0){
        [self showCustomIOS7AlertViewWithMessages:errors title:@"В ходе обновления возникли ошибки:"];
    }
    priceUpdater = nil;
}

- (void)BVAPriceUpdater:(BVAPriceUpdater *)updater didStopUpdatingWithErrors:(NSArray *)errors{
    // Выставляем флаг
    isManagedObjectContextUpdating = NO;
    // останавливаем анимацию
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [self.activityIndicatorUpdatingData stopAnimating];
    }];
    [self showCustomIOS7AlertViewWithMessages:errors title:@"Обновление каталога остановлено из-за следующих ошибок:"];
    priceUpdater = nil;
}

-(void)BVAPriceUpdaterDidStartUpdating:(BVAPriceUpdater *)updater{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        self.labelDataLastUpdate.text = @"Обновляем каталог...";
    }];
}

#pragma mark Observing

// Устанавливаем "прослушку" за объектом appSettings, чтобы быть в курсе изменений
-(void) addObserversForAppSettings{
    [self.appSettings addObserver:self forKeyPath:@"clientsListLastUpdate" options:NSKeyValueObservingOptionNew context:nil];
    [self.appSettings addObserver:self forKeyPath:@"priceLastUpdate" options:NSKeyValueObservingOptionNew context:nil];
    [self.appSettings addObserver:self forKeyPath:@"currentTA" options:NSKeyValueObservingOptionNew context:nil];
}

// Убираем "прослушку" за объектом appSettings
-(void) removeObserversForAppSettings{
    [self.appSettings removeObserver:self forKeyPath:@"clientsListLastUpdate"];
    [self.appSettings removeObserver:self forKeyPath:@"priceLastUpdate"];
    [self.appSettings removeObserver:self forKeyPath:@"currentTA"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"clientsListLastUpdate"]){
        [self updateLabelDataLastUpdate];
    }
    else if([keyPath isEqualToString:@"priceLastUpdate"]){
        [self updateLabelDataLastUpdate];
    }
    else if([keyPath isEqualToString:@"currentTA"]){
        [self updateLabelTAName];
    }
}

#pragma mark CustomAlertView

// Показываем алерт на основе списка ошибок или сообщений
-(void) showCustomIOS7AlertViewWithMessages:(NSArray *) messages title:(NSString *) title
{
    NSString *text = [NSString string];
    for(int i=0;i<messages.count;i++)
    {
        NSObject *message = [messages objectAtIndex:i];
        if( [message isMemberOfClass:[NSError class]] )
            text = [text stringByAppendingFormat:@"\n%@ userInfo: %@",[(NSError *) message localizedDescription],[(NSError *) message userInfo]];
        else {
            text = [text stringByAppendingFormat:@"\n%@",message];
        }
    }
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 600, 660)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 590, 50)];
    //UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 590, 50)];
    UILabel *title_label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 600, 50)];
    title_label.text = title;
    title_label.textAlignment = NSTextAlignmentCenter;
    title_label.textColor = [UIColor colorWithRed:0.5f green:0.1f blue:0.1f alpha:1.0f];
    title_label.font = [UIFont systemFontOfSize:22.0f];
    UIFont *font = [UIFont systemFontOfSize:10.0f];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, 600, 600)];
    scrollView.scrollEnabled = YES;
    [label setFont:font];
    
    [view addSubview:title_label];
    [view addSubview:scrollView];
    [scrollView addSubview:label];
    [label setNumberOfLines:0];
    label.text = text;
    [label sizeToFit];
    scrollView.contentSize = [label frame].size;
    [alertView setContainerView:view];
    [alertView show];
}

@end

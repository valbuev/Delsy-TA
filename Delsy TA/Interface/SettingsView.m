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

@interface SettingsView ()

@end

@implementation SettingsView

@synthesize btnUpdateAllPhotos;
@synthesize btnUpdateClientList;
@synthesize btnUpdatePriceList;
@synthesize activityIndicatorAllPhotos;
@synthesize activityIndicatorClientList;
@synthesize activityIndicatorPriceList;
@synthesize labelClientListLastUpdate;
@synthesize labelPriceListLastUpdate;
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

// Нажата кнопка обновления Списка клиентов,
// создаем updater, отдаем ему контекст, записываемся в делегаты и стартуем обновление
- (IBAction)OnBtnUpdateClientListClick:(id)sender{
    // Если сейчас идет обновление, то запрещаем действия
    if(isManagedObjectContextUpdating)
        return;
    clientListUpdater = [[BVAClientListUpdater alloc] init];
    clientListUpdater.managedObjectContext = self.managedObjectContext;
    clientListUpdater.delegate = self;
    [clientListUpdater startUpdating];
}

// Нажата кнопка обновления Каталога,
// создаем updater, отдаем ему контекст, записываемся в делегаты и стартуем обновление
- (IBAction)OnBtnUpdatePriceListClick:(id)sender{
    // Если сейчас идет обновление, то запрещаем действия
    if(isManagedObjectContextUpdating)
        return;
    
}
- (IBAction)OnBtnUpdateAllPhotosClick:(id)sender{
    // Если сейчас идет обновление, то запрещаем действия
    if(isManagedObjectContextUpdating)
        return;
    
}

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
    [self updateLabelClientListLastUpdate];
    [self updateLabelPriceListLastUpdate];
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
-(void) updateLabelClientListLastUpdate{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        self.labelClientListLastUpdate.text =
            [self dateFormaterForLastUpdateLabels:self.appSettings.clientsListLastUpdate];
    }];
}
-(void) updateLabelPriceListLastUpdate{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        self.labelPriceListLastUpdate.text =
            [self dateFormaterForLastUpdateLabels:self.appSettings.priceLastUpdate];
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

/**********     Все ячейки - статичны, поэтому функции кол-ва секций, ячеек в секции, редактирования ячеек и генерирования ячеек не реализуем     *********/

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
    // Выставляем флаг
    isManagedObjectContextUpdating = NO;
    // Посылаем в основной поток, чтобы сразу изменения сразу вступили в силу
    // останавливаем анимацию
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [self.activityIndicatorClientList stopAnimating];
    }];
}

- (void)BVAClientListUpdater:(BVAClientListUpdater *)updater didStopUpdatingWithErrors:(NSArray *)errors{
    // Выставляем флаг
    isManagedObjectContextUpdating = NO;
    // останавливаем анимацию
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [self.activityIndicatorClientList stopAnimating];
    }];
}

-(void)BVAClientListUpdaterDidStartUpdating:(BVAClientListUpdater *)updater{
    // Выставляем флаг
    isManagedObjectContextUpdating = YES;
    // запускаем анимацию
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [self.activityIndicatorClientList startAnimating];
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
        [self updateLabelClientListLastUpdate];
    }
    else if([keyPath isEqualToString:@"priceLastUpdate"]){
        [self updateLabelPriceListLastUpdate];
    }
    else if([keyPath isEqualToString:@"currentTA"]){
        [self updateLabelTAName];
    }
}

@end

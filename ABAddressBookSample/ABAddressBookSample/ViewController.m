//
//  ViewController.m
//  ABAddressBookSample
//
//  Created by Sunil Maurya on 2/15/16.
//  Copyright © 2016 AffleAppstudioz. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,ABNewPersonViewControllerDelegate,ABPersonViewControllerDelegate,ABUnknownPersonViewControllerDelegate,UINavigationControllerDelegate>
{
    ABAddressBookRef addressBook;
    __weak IBOutlet UITableView *tableVContacts;
    NSMutableArray *arrContacts;
    NSIndexPath *selectedIndexPath;
    ABPersonViewController *pickerV;
}
@property (nonatomic) ABAddressBookRef addressBook_cf;
@property(strong,nonatomic) ABPeoplePickerNavigationController *pickerNav;

- (IBAction)btnAddContactClick:(id)sender;
@end

@implementation ViewController
@synthesize pickerNav = _pickerNav;
- (void)viewDidLoad {
    [super viewDidLoad];
    [tableVContacts setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    arrContacts = [[NSMutableArray alloc]init];
    //[self getAllPhonebookContacts];
   //[self addContactToContactBook];
    
    [self getContactsFromPhoneBookWithSorting];
   // [self deleteContactFromContactBook];
    //[self updateContactInAddressBook];
    self.navigationController.navigationBar.hidden = NO;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//MARK:- TableView DataSource/Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrContacts.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"ContactCell";
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    ABRecordRef person = (__bridge ABRecordRef)[arrContacts objectAtIndex:indexPath.row];
    //getting name of contact
    
    NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    NSString *lastName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
    if(firstName == nil && lastName == nil){
        cell.textLabel.text = @"No name assigned";
    }
    else{
        if(firstName == nil)
            firstName = @"";
        if(lastName == nil)
            lastName = @"";
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
    }
    
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedIndexPath = indexPath;
    //[self selectViaABPersonNewViewController:NO];
    [self selectViaABPersonViewController];
    //[self selectViaABUnknownPersonViewController];
}
-(void) selectViaABPersonNewViewController:(BOOL) isNew{
    ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init] ;
    picker.newPersonViewDelegate = self;
    picker.navigationItem.title=@"Edit Contact";
    if(isNew == NO){
        picker.displayedPerson = (__bridge ABRecordRef)[arrContacts objectAtIndex:selectedIndexPath.row];
        NSLog(@"ID:%i",(ABRecordGetRecordID(picker.displayedPerson)));
        picker.navigationItem.title=@"Edit Contact";
    }
    else{
        picker.navigationItem.title=@"Add Contact";
    }
    self.navigationItem.backBarButtonItem = nil;
    
    picker.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:picker animated:YES];
}
-(void) selectViaABPersonViewController{
    pickerV = [[ABPersonViewController alloc] init] ;
    pickerV.personViewDelegate = self;
    pickerV.allowsEditing = YES;
    pickerV.allowsActions = NO;
    pickerV.displayedPerson = (__bridge ABRecordRef)[arrContacts objectAtIndex:selectedIndexPath.row];
    pickerV.navigationItem.title=@"Edit Contact";
    pickerV.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(closePeopleViewPicker)];
    self.navigationItem.hidesBackButton = YES;
    pickerV.navigationItem.backBarButtonItem = backBtn;
    self.navigationController.navigationBarHidden = NO;
    //[self addCustomNavigationBarIniOS9];
    self.navigationController.delegate = self;
    [self.navigationController pushViewController:pickerV animated:YES];
    
}
//MARK:- Navigation Controllar delegate
//call it via self.navigationController.delegate = self;
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    //set up the ABPeoplePicker controls here to get rid of he forced cacnel button on the right hand side but you also then have to
    // the other views it pcuhes on to ensure they have to correct buttons shown at the correct time.
    /*
    navigationController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPerson:)];
    
    navigationController.topViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];*/
    NSLog(@"%@",navigationController.topViewController);
    if(navigationController.topViewController!=self){
        UIView * navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
        UIImageView *imgVBG = [[UIImageView alloc] initWithFrame:navView.frame];
        imgVBG.image = [UIImage imageNamed:@"nav_bg"];
        [navView addSubview:imgVBG];
        UIButton *btnBack = [[UIButton alloc] initWithFrame:CGRectMake(-3, 20, 70, 44)];
        [btnBack setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btnBack setTitle:@"Back" forState:UIControlStateNormal];
        [btnBack addTarget:self action:@selector(closePeopleViewPicker) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:btnBack];
        [navigationController.topViewController.view addSubview:navView];
    }
}
-(void) closePeopleViewPicker{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void) selectViaABUnknownPersonViewController{
    ABUnknownPersonViewController *picker = [[ABUnknownPersonViewController alloc] init] ;
    picker.unknownPersonViewDelegate = self;
    picker.allowsActions = NO;
    picker.displayedPerson = (__bridge ABRecordRef)[arrContacts objectAtIndex:selectedIndexPath.row];
    picker.allowsAddingToAddressBook = YES;
    picker.navigationItem.title=@"Edit Contact";
    picker.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
    
    [self.navigationController pushViewController:picker animated:YES];
}
//MARK:- Get All Contacts
-(void) getAllPhonebookContacts
{
    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
        if (!granted){
            //4
            NSLog(@"Just denied");
            return;
        }
        if(!self.addressBook_cf){
            self.addressBook_cf = ABAddressBookCreate();
        }
        // Register a callback to receive notifications when the Address Book database is modified.
        //
        // Don't pass this address book instance into addressBook property of ABPeoplePickerNavigationController or else
        // callback wont function properly.
        if(!self.addressBook_cf){
            self.addressBook_cf = ABAddressBookCreate();
        }
        ABAddressBookRegisterExternalChangeCallback (self.addressBook_cf, addressBookExternalChangeCallback, (__bridge void *)(self));
        [self getContactsFromPhoneBook];
    });
}
void addressBookExternalChangeCallback (ABAddressBookRef addressBook,
                                        CFDictionaryRef info,
                                        void *context
                                        )
{
}
-(void) getContactsFromPhoneBook{
    [arrContacts removeAllObjects];
    if(addressBook == NULL || addressBook==nil)
        addressBook = ABAddressBookCreateWithOptions(nil, nil);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);

    NSArray *allContacts = (__bridge NSArray *)people;
    [arrContacts addObjectsFromArray:allContacts];
    if(arrContacts.count)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableVContacts reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        });
        
    }
//    CFRelease(people);
//    CFRelease(addressBook);
}

-(void) getContactsFromPhoneBookWithSorting{
    
    [arrContacts removeAllObjects];
    if(addressBook == NULL || addressBook==nil)
        addressBook = ABAddressBookCreateWithOptions(nil, nil);
    
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault,
                                                               CFArrayGetCount(people),
                                                               people);
    
    /*
     //sorting by specific key:-kABPersonSortByLastName, kABPersonSortByFirstName
     
    CFArraySortValues(peopleMutable,
                      CFRangeMake(0, CFArrayGetCount(peopleMutable)),
                      (CFComparatorFunction) ABPersonComparePeopleByName,
                      kABPersonSortByLastName);
    */
    
    // or to sort by the address book's choosen sorting technique
    //
     CFArraySortValues(peopleMutable,
                       CFRangeMake(0, CFArrayGetCount(peopleMutable)),
                       (CFComparatorFunction) ABPersonComparePeopleByName,
                       (void*) ABPersonGetSortOrdering());
    
    CFRelease(people);
    [arrContacts addObjectsFromArray:(__bridge NSArray * _Nonnull)(peopleMutable)];
    if(arrContacts.count)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableVContacts reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        });
        
    }
    CFRelease(peopleMutable);
}



//MARK:- Button Add Contact Action
- (IBAction)btnAddContactClick:(id)sender {
    [self selectViaABPersonNewViewController:YES];
}

//MARK:- Contact View UI Adding New Person Delagate
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(nullable ABRecordRef)person{
    [self.navigationController popViewControllerAnimated:YES];
    if(person == nil){
        NSLog(@"Cancel Button Clicked...");
    }
    else{
        NSLog(@"Done Button Clicked...");
        
        NSLog(@"Name:%@",(__bridge NSString *)(ABRecordCopyValue(newPersonView.displayedPerson, kABPersonFirstNameProperty)));
        NSLog(@"Name:%@",(__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty)));
        NSLog(@"ID:%i",(ABRecordGetRecordID(newPersonView.displayedPerson)));
        NSLog(@"ID:%i",(ABRecordGetRecordID(person)));
        //fetching & updating table
        addressBook = nil;
        [self getContactsFromPhoneBook];
        
        //get info while new/edit/update contact
        ABRecordRef updatedPerson;
        if(ABRecordGetRecordID(newPersonView.displayedPerson) == -1){//new
            updatedPerson = person;
        }
        else{//updated
            updatedPerson = [self getPersonViaRecordID:ABRecordGetRecordID(person)];
        }
        
        NSLog(@"Name:%@",(__bridge NSString *)(ABRecordCopyValue(updatedPerson, kABPersonFirstNameProperty)));
    }
}
//MARK:- Contact View UI Show Person Delagate
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    NSLog(@"Name:%@",(__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty)));
    [self.navigationController popViewControllerAnimated:YES];
    return YES;
}

//MARK:- Contact View UI Show Person Delagate
- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownCardViewController didResolveToPerson:(nullable ABRecordRef)person{
    NSLog(@"Name:%@",(__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty)));
    [self.navigationController popViewControllerAnimated:YES];
}
-(ABRecordRef) getPersonViaRecordID:(ABRecordID) recID{
    if(addressBook == NULL || addressBook==nil)
        addressBook = ABAddressBookCreateWithOptions(nil, nil);
    ABRecordRef rec = ABAddressBookGetPersonWithRecordID(addressBook, recID);
    return rec;
}

-(void) addCustomNavigationBarIniOS9{
    UIView * navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
    UIImageView *imgVBG = [[UIImageView alloc] initWithFrame:navView.frame];
    imgVBG.image = [UIImage imageNamed:@"nav_bg"];
    [navView addSubview:imgVBG];
    UIButton *btnBack = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 70, 44)];
    [btnBack setTitle:@"Back" forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(closePeopleViewPicker) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:btnBack];
    [self.navigationController.navigationBar addSubview:navView];
}

//MARK:- Touch Delegate
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

//MARK:- add contact manually in Contact Book

-(void)addContactToContactBook
{
    CFErrorRef error = nil;
    ABAddressBookRef addressBookForAddContact  = ABAddressBookCreateWithOptions(NULL, &error);
    ABRecordRef person = ABPersonCreate();
    CFTypeRef firstName = @"hellooo";
    CFTypeRef officeName = @"Affle";
    CFTypeRef lastName = @"kumar";
    CFTypeRef phone = @"9087654321";
    
    ABRecordSetValue(person, kABPersonFirstNameProperty, firstName,&error);
    ABRecordSetValue(person, kABPersonOrganizationProperty, officeName ,&error);
    ABRecordSetValue(person, kABPersonLastNameProperty , lastName  , &error);
    ABRecordSetValue(person, kABPersonPhoneProperty , phone  , &error);
    ABMutableMultiValueRef phoneNumberMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(phoneNumberMultiValue, @"07972574949", (CFStringRef)@"iPhone", NULL);
    ABMultiValueAddValueAndLabel(phoneNumberMultiValue, @"01234567890", (CFStringRef)@"Work", NULL);
    ABMultiValueAddValueAndLabel(phoneNumberMultiValue, @"08701234567", (CFStringRef)@"0870", NULL);
    ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, nil);
    CFRelease(phoneNumberMultiValue);
    
    if(!(ABAddressBookAddRecord(addressBookForAddContact, person, &error)))
    {
        NSLog(@"error%@",error);
    }
    
    if (!(ABAddressBookHasUnsavedChanges(addressBookForAddContact))) {
        NSLog(@"Failed.");
    }
    
    CFRelease(addressBookForAddContact);
    
}

//MARK:- delete contact manually in Contact Book

-(void)deleteContactFromContactBook
{
    
    if(arrContacts.count)
    {
        CFErrorRef error = nil;
        ABAddressBookRef addressBookForAddContact  = ABAddressBookCreateWithOptions(NULL, &error);
        ABRecordRef person = (__bridge ABRecordRef)([arrContacts lastObject]);
        
        NSLog(@"object to delete %@\n",CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty)));
        
        
        if(!(ABAddressBookRemoveRecord(addressBookForAddContact, person, &error)))
        {
            NSLog(@"%@",error);
        }
        
        if (!(ABAddressBookHasUnsavedChanges(addressBookForAddContact))) {
            NSLog(@"Failed.");
        }
        
        CFRelease(addressBookForAddContact);
    }
    
}


//MARK:- update contact manually in Contact Book

-(void)updateContactInAddressBook
{
    if(arrContacts.count){
        CFErrorRef error = nil;
        ABAddressBookRef addressBookForAddContact  = ABAddressBookCreateWithOptions(NULL, &error);
        ABRecordRef person = (__bridge ABRecordRef)([arrContacts lastObject]);
        ABMutableMultiValueRef phoneNumberMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(phoneNumberMultiValue, @"123456789", (CFStringRef)@"iPhone", NULL);
        ABMultiValueAddValueAndLabel(phoneNumberMultiValue, @"123456789", (CFStringRef)@"Work", NULL);
        ABMultiValueAddValueAndLabel(phoneNumberMultiValue, @"123456789", (CFStringRef)@"0870", NULL);
        ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, nil);
        
        
        if(!(ABAddressBookRemoveRecord(addressBookForAddContact, person, &error)))
        {
            NSLog(@"%@",error);
        }
        
        if (!(ABAddressBookHasUnsavedChanges(addressBookForAddContact))) {
            NSLog(@"Failed.");
        }
        
        CFRelease(addressBookForAddContact);
    }
    
    
}
@end

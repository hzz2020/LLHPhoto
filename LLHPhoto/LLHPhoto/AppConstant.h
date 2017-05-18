//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]
//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		SYSTEM_VERSION								[[UIDevice currentDevice] systemVersion]
#define		SYSTEM_VERSION_EQUAL_TO(v)					([SYSTEM_VERSION compare:v options:NSNumericSearch] == NSOrderedSame)
#define		SYSTEM_VERSION_GREATER_THAN(v)				([SYSTEM_VERSION compare:v options:NSNumericSearch] == NSOrderedDescending)
#define		SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)	([SYSTEM_VERSION compare:v options:NSNumericSearch] != NSOrderedAscending)
#define		SYSTEM_VERSION_LESS_THAN(v)					([SYSTEM_VERSION compare:v options:NSNumericSearch] == NSOrderedAscending)
#define		SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)		([SYSTEM_VERSION compare:v options:NSNumericSearch] != NSOrderedDescending)
//-------------------------------------------------------------------------------------------------------------------------------------------------

#define     SCREEN_WIDTH                        ([UIScreen mainScreen].bounds.size.width)
#define     SCREEN_HEIGHT                       ([UIScreen mainScreen].bounds.size.height)
#define     SINGLE_LINE_WIDTH                   (1 / [UIScreen mainScreen].scale)

#define     DOCUMENTPATH                        ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0])
#define     myIdentifier                        @"qh8687"

//-------------------------------------------------------------------------------------------------------------------------------------------------


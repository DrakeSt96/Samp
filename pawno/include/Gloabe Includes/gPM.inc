#if defined _g_P_M___
* - -
*
*	Projekt:		gPM
*	Lizenz:			GNU Version 3
*	Datei:			gPM.inc
*	Letztes Update: 9.12.2015	Version:		1.3.3
*
*       gPM  -  by Daniel "Goldkiller"
*
*
*       Credits:
*			- Slice ( Transaction )
*
*
*
*   Changelog:
*       1.3.3 :
*           - Datenbank wird automatisch erzeugt und zur Weiterverwendung vorbereitet
*           - Zwei potenzielle Speicherlücken geschlossen
*           - SQL Kommandos etwas angepasst
*           - Fehlermeldung überarbeitet bei *_FILTER, falls keine Nachrichten vorhanden
*           - Crash behoben bei zu vielen Nachrichten im *_FILTER Ergebnis
*           - ID Entfernt aus *_MSG_FILTER Überschrift
*           - Nachrichten Robot angepasst
*           - Fehlende Aktion bei "Zurück" im DIALOG_PM_USER_VERARBEITUNG hinzugefügt
*           - MAX_QUERY_RESULTS auf 15 reduziert
*           - Dialog Style für bessere Übersicht auf DIALOG_STYLE_TABLIST_HEADERS umgestellt
*           - Code für den EDIT_MODE entfernt
*           - Weitere Hilfen als Informationshinweis ergänzt
*           - "User Übersicht" in "Benutzer Suche" umbenannt
*           - Doppelte Nachricht aus gPM_SendMessageArray entfernt
*           - Gültigkeits Bereich von Funktionen angepasst
*           - Öffnen des Postfaches von COMMAND auf Funktion umgestellt
*           - ZCMD Abhängigkeit entfernt
*
*       1.3.2 :
*           - gPM_GetNewMessages auf SQL Count umgeschrieben
*           - Index out of Bounce check für gPM_OnLogin
*           - DB Funktionen auf Änderungen in SA-MP 0.3.7 angepasst
*           - Debug Informationen entfernt bei DIALOG_PM_EINGANG_FILTER
*           - Einige Dialoge auf DIALOG_STYLE_TABLIST umgestellt
*           - Fehler behoben, der bei zu langen Texten trotz sizeof() bei db_get_result Variablen überschreibt
*           - Fehler behoben, bei dem auf negativen Index zuzegriffen wird in *Filter Dialogen
*
*       1.3.1 :
*           - gPM_OnLogin hinzugefügt
*           - Umständliches Verfahren zum authentifizieren des Benutzers entfernt
*
*       1.3 :
*            - Nachricht kann nun an mehrere User gleichzeitig versendet werden
*            - Einfaches hinzufügen / entfernen von Usern für das Versenden
*            - Fehler behoben, dass 'strins' zum Absturz bringt
*            - Nachricht angepasst falls Suchkriterium zu viele Ergebnisse erzeugt
*
*       1.2 :
*            - Userschutz hinzugefügt
*            - Texte komplett in Deutsch geändert
*            - Diverse Kleinigkeiten
*
*
* - -
#endif

#include </Gloabe Includes/a_samp>

#define DATABASE "gPM.sqlite"
#define ROBOT_USER_NAME "Robot"

#define MAX_QUERY_RESULTS 15

#define SHOW_NEXT_PAGES
#define SHOW_PREVIOUS_PAGES

// #define PLAY_SOUND
#if defined PLAY_SOUND
	#define INCOMING_MESSAGE_SOUND "www.sa-mp.de/sound.mp3"
#endif

#define INVALID_USER_ID -1
#define INVALID_LIST_ITEM -1

#define MAX_INPUT_PAGES 5
#define MAX_MESSAGE_RECEIVERS 20
#define INPUT_SIZE 128

#define MARK_NEW_MESSAGES "*Neu"
#define MARK_UNREAD_MESSAGES "*Ungelesen"

#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_RED 0xFF0000FF
#define COL_WHITE "{FFFFFF}"
#define COL_GREY "{88ABAB}"
#define COL_BLUE "{0000FF}"
#define COL_BLUE_LIGHT "{3232FF}"
#define COL_GREEN "{00FF00}"
#define COL_GREEN_LIGHT "{73FF73}"
#define COL_RED "{FF0000}"
#define COL_RED_LIGHT "{FF4040}"
#define COL_ORANGE "{FF9900}"
#define COL_ORANGE_LIGHT "{FFBF5E}"

#define DATE_FORMAT "%d.%m.%Y"

#define GPM_USERCALL_FUNCTION "gPM_UserCall"

#define GPM_MAX_STRING ( MAX_INPUT_PAGES * INPUT_SIZE + 20 )


static
	g_iRobotID,
	g_iUserID[ MAX_PLAYERS ],
	g_iLoggedIn[ MAX_PLAYERS char],
	g_supUserInput[ MAX_PLAYER_NAME ],
	
	g_supMessageInput[ GPM_MAX_STRING ], 
	g_supMessageSingleInput[ INPUT_SIZE ],
	g_sUserMessageInput[ MAX_PLAYERS ][ MAX_INPUT_PAGES ][ INPUT_SIZE char],
	g_iUserMessageInput[ MAX_PLAYERS char ],
	g_iDialogEdition[ MAX_PLAYERS char],
	
	g_aiUserMessageReceivers[ MAX_PLAYERS ][ MAX_MESSAGE_RECEIVERS ],
	g_iUsersMessageReceivers[ MAX_PLAYERS char],

	g_sUserInput[ MAX_PLAYERS ][ MAX_PLAYER_NAME char ],
	g_iUserInput[ MAX_PLAYERS ],
	g_iRowUniqueID[ MAX_PLAYERS ][ MAX_QUERY_RESULTS ],
	
	g_iResults[ MAX_PLAYERS ],
	g_iPage[ MAX_PLAYERS ],

	g_sQuery[ 160  + ( MAX_INPUT_PAGES * INPUT_SIZE )  ],
	DBResult:g_dbrQuery,
	DB:g_dbPM;
	
	
enum ( <<= 1 ) {
	MessageStatus_Read = 1,
	MessageStatus_DEL_Sender, // del von sender ( postausgang )
	MessageStatus_DEL_Empfaenger // del von empfaenger ( posteingang )
}

enum ( += 1 ) {
	DIALOG_EDITION_NORMAL,
	DIALOG_EDITION_ADD_EMPFAENGER,
	DIALOG_EDITION_FILTER
}

enum ( += 1 ) {
	USERNAME_CANT_ADD = 0,
	USERNAME_ADDED,
	USERNAME_ALREADY_IN,
	USERNAME_REMOVED
}

enum ( += 1 ) {
	DELETE_MESSAGE_BY_SENDER = 0,
	DELETE_MESSAGE_BY_EMPFAENGER
}

enum ( += 1 ) {
	DIALOG_PM_MENU = 12425,
	DIALOG_PM_EINGANG,
	DIALOG_PM_EINGANG_EMPTY,
	DIALOG_PM_EINGANG_MSG,
	DIALOG_PM_EINGANG_ENTF_ABFRAGE,
	DIALOG_PM_EINGANG_FILTER,
	DIALOG_PM_EINGANG_FILTER_MSG,
	DIALOG_PM_EINGANG_ENTF,
	DIALOG_PM_AUSGANG,
	DIALOG_PM_AUSGANG_EMPTY,
	DIALOG_PM_AUSGANG_MSG,
	DIALOG_PM_AUSGANG_ENTF_ABFRAGE,
	DIALOG_PM_AUSGANG_ENTF,
	DIALOG_PM_AUSGANG_FILTER,
	DIALOG_PM_AUSGANG_FILTER_MSG,
	DIALOG_PM_SCHREIBEN_USER,
	DIALOG_PM_SCHREIBEN_TEXT,
	DIALOG_PM_SCHREIBEN_BEARBEITEN,
	DIALOG_PM_SCHREIBEN_MENU,
	DIALOG_PM_SCHREIBEN_INFO,
	DIALOG_PM_SCHREIBEN_VERSENDET,
	DIALOG_PM_SCHREIBEN_EMPF_EDIT,
	DIALOG_PM_USER_UEBERSICHT,
	DIALOG_PM_USER_UEBERSICHT_QUERY,
	DIALOG_PM_USER_VERARBEITUNG,
}

gPM_Init() {
	print(" >> gPM FS: Init");
	g_dbPM = db_open( DATABASE );
	if( g_dbPM ) {
		for(new i = 0 ; i < MAX_PLAYERS ; i++) {
		    if( IsPlayerConnected( i ) ) {
		        gPM_OnPlayerConnect( i );
		    }
		}
		format( g_sQuery , sizeof(g_sQuery) , "CREATE TABLE IF NOT EXISTS [Nachricht] (\
												[NachrichtID] INTEGER  PRIMARY KEY AUTOINCREMENT NOT NULL,\
												[SenderID] INTEGER  NOT NULL,\
												[EmpfaengerID] INTEGER  NOT NULL,\
												[Status] INTEGER  NOT NULL,\
												[Tag] DATE  NOT NULL,\
												[Uhrzeit] TIME  NOT NULL,\
												[Referenz] INTEGER  NULL,\
												[Text] VARCHAR(%d) NOT NULL\
											)", (MAX_INPUT_PAGES * INPUT_SIZE)
		);
		db_free_result( db_query( g_dbPM , g_sQuery	));
		g_sQuery[0] = '\0';
		format( g_sQuery , sizeof(g_sQuery) , "CREATE TABLE [User] (\
												[UserID] INTEGER  NOT NULL PRIMARY KEY AUTOINCREMENT,\
												[Name] VARCHAR(%d)  UNIQUE NOT NULL\
											)", MAX_PLAYER_NAME
		);
		db_free_result( db_query( g_dbPM , g_sQuery	));
		g_sQuery[0] = '\0';
		format( g_sQuery , sizeof(g_sQuery) , "SELECT * FROM [User] WHERE [Name] = '%s'", ROBOT_USER_NAME );
		g_dbrQuery = db_query( g_dbPM , g_sQuery );
		g_sQuery[0] = '\0';
		if( db_num_rows(g_dbrQuery) == 0 ) {
			gPM_AddUsername( ROBOT_USER_NAME );
		}
		g_iRobotID = gPM_GetUserID( ROBOT_USER_NAME );
		db_free_result( g_dbrQuery );
		// gPM_AddUsers("gPM.index"); <-- automatisch eine liste auf Usern hinzufügen
		db_free_result( db_query( g_dbPM , "PRAGMA synchronous = OFF" ) );
		printf("gPM <> Database ID: %d", _:g_dbPM );
		printf("gPM <> Users: %d" , gPM_GetUsers() );
		printf("gPM <> Nachrichten: %d" , gPM_GetNachrichten() );
	}
	else {
		printf("gPM <> FEHLER: Datenbank \"%s\" konnte nicht geöffnet / erzeugt werden." , DATABASE );
	    return 0;
	}
	return 1;
}

gPM_Close() {
	print(" >> gPM FS: Close");
	if( g_dbPM ) {
		db_close( g_dbPM );
	}
	return 1;
}

static gPM_AddUsername( username[] ) {
	format( g_sQuery , sizeof( g_sQuery ) , "INSERT INTO `User` (`Name`) VALUES ('%s')" , db_escape( username ) );
	db_free_result( db_query( g_dbPM , g_sQuery ) );
	g_sQuery[0] = '\0';
	printf("gPM <> Benutzer '%s' hinzugefügt" , username );
	return 1;
}

gPM_OnPlayerConnect(playerid) {
	if( g_dbPM ) {
		new
			sName[ MAX_PLAYER_NAME ];
		GetPlayerName( playerid , sName , sizeof( sName ) );
		g_iUserID[ playerid ] = gPM_GetUserID( sName );
		g_iResults[ playerid ] = 0;
		g_iPage[ playerid ] = 0;
		g_iLoggedIn{ playerid } = 0;

	    if( g_iUserID[playerid] == INVALID_USER_ID ) {
	        new
				sString[ 128+32 ];
			gPM_AddUsername( sName );
			g_iUserID[ playerid ] = gPM_GetUserID( sName );
			format( sString , sizeof( sString ) , "Hallo %s, probier doch unser neues Nachrichten-System aus. Mehr dazu unter /gpm" , sName );
			SendClientMessage( playerid , COLOR_WHITE , sString );
			gPM_SendMessage( g_iRobotID , g_iUserID[ playerid ] , "Willkommen in deinem persönlichem Postfach. Du hast nun die Möglichkeit, an Benutzer Nachrichten zu versenden oder von diesen Nachrichten zu empfangen. Viel Spaß damit! \n\n- Diese Nachricht wurde automatisch versendet" , false );
	    }
		return 1;
	}
	return 0;
}

gPM_OnPlayerDisconnect(playerid, reason ) {
	if( g_dbPM ) {
		#pragma unused reason
		g_iUserID[playerid] = INVALID_USER_ID;
		g_iLoggedIn{ playerid } = 0;
		return 1;
	}
	return 0;
}

static gPM_GetNewMessages( userid ) {
	new
		iCount;
	format( g_sQuery , sizeof( g_sQuery ) , "SELECT COUNT(*) FROM `Nachricht` WHERE `EmpfaengerID` = %d AND NOT(`Status` & %d )" , userid , MessageStatus_Read );
	g_dbrQuery = db_query( g_dbPM , g_sQuery );
	iCount = db_num_fields( g_dbrQuery );
	g_sQuery[0] = '\0';
	db_free_result( g_dbrQuery );
	return iCount;
}

static gPM_GetUserID( name[] ) {
	new
		iUserID = INVALID_USER_ID;
	format( g_sQuery , sizeof( g_sQuery ) , "SELECT `UserID` FROM `User` WHERE `Name` = '%s'" , db_escape( name ) );
	g_dbrQuery = db_query( g_dbPM , g_sQuery );
	if( db_num_rows( g_dbrQuery ) == 1 ) {
		iUserID = db_num_fields( g_dbrQuery , 0);
	}
	g_sQuery[0] = '\0';
	db_free_result( g_dbrQuery );
	return iUserID;
}

static gPM_SendMessage( senderid , receiverid , const message[] , bool:send_notice = true) {
	format( g_sQuery , sizeof( g_sQuery ) , "INSERT INTO `Nachricht` (`SenderID`,`EmpfaengerID`,`Status`,`Tag`,`Uhrzeit`,`Text`) VALUES ('%d','%d','%d', date('now') ,time('now'),'%s')" , senderid , receiverid , 0 , message );
	db_free_result( db_query( g_dbPM , g_sQuery ) );
	g_sQuery[0] = '\0';
	if(send_notice) {
		for(new i = 0 ; i < MAX_PLAYERS ; i++) {
			if( IsPlayerConnected( i ) ) {
				if( g_iUserID[ i ] == receiverid ) {
					gPM_OnPlayerReceiveMessage( i , senderid , message );
					return 1;
				}
			}
		}
	}
	return 1;
}

static gPM_SendMessageArray( senderid , array[ MAX_MESSAGE_RECEIVERS ] , const message[] , count ) {
	new
	    j;
	db_free_result( db_query( g_dbPM , "BEGIN" ) );
	for(new i = 0 ; i < count ; i++ ) {
		format( g_sQuery , sizeof( g_sQuery ) , "INSERT INTO `Nachricht` (`SenderID`,`EmpfaengerID`,`Status`,`Tag`,`Uhrzeit`,`Text`) VALUES ('%d','%d','%d', date('now') ,time('now'),'%s')" , senderid , array[ i ] , 0 , message );
		db_free_result( db_query( g_dbPM , g_sQuery ) );
	}
	db_free_result( db_query( g_dbPM , "COMMIT" ) );
	g_sQuery[0] = '\0';
	for(new i = 0 ; i < MAX_PLAYERS ; i++) {
		if( IsPlayerConnected( i ) ) {
		    for( j = 0 ; j < count ; j++ ) {
				if( g_iUserID[ i ] == array[ j ] ) {
					gPM_OnPlayerReceiveMessage( array[ j ] , senderid , message );
					break;
				}
		    }
		}
	}
	return 1;
}

static gPM_DeleteMessage( typ , messageid) {
	if( typ == DELETE_MESSAGE_BY_SENDER ) {
		format( g_sQuery , sizeof( g_sQuery ) , "UPDATE `Nachricht` SET `Status` = `Status` | %d WHERE `NachrichtID` = %d" , MessageStatus_DEL_Sender , messageid);
	}
	else if( typ == DELETE_MESSAGE_BY_EMPFAENGER ) {
		format( g_sQuery , sizeof( g_sQuery ) , "UPDATE `Nachricht` SET `Status` = `Status` | %d WHERE `NachrichtID` = %d" , MessageStatus_DEL_Empfaenger , messageid);
	}
	if(g_sQuery[0]) {
		db_free_result( db_query( g_dbPM , g_sQuery ) );
		return 1;
	}
	return 0;
}

static gPM_OnPlayerReceiveMessage( playerid , send_userid , const message[] ) {
	#pragma unused message
	new
		sString[ 128 ];
	format( sString , sizeof( sString ) , "* gPM: Du hast eine Nachricht von Benutzer "#COL_GREY"%s"#COL_WHITE" empfangen" , gPM_GetUsername( send_userid ) );
	SendClientMessage( playerid , COLOR_WHITE , sString );
	#if defined PLAY_SOUND
	PlayAudioStreamForPlayer( playerid , INCOMING_MESSAGE_SOUND ); 
	#endif
	return 1;
}

static gPM_StripMessageLines( message[ GPM_MAX_STRING ] ) {
	#define SPLIT_LEN 50
	new
		bool:_bBasic = true,
		_iParts,
		_iCount,
		_iTempLen = 0,
		_iPos = 0,
		_iTempPos = 0,
		_iLen;
	_iLen = strlen( message );
	while( ( _iPos = strfind( message , " " , false  ,_iPos + 1) )  != -1 )  {
		_iCount++;
		_iTempLen += ( _iPos - _iTempPos );
		_iTempPos = _iPos;
		if( _iTempLen >= SPLIT_LEN ) {
		    if( _iPos++  < sizeof( message ) ) {
				strins( message , "\n" , _iPos );
				_iCount = 0;
				_iPos += 2;
				_bBasic = false;
				_iTempLen = 0;
			}
		}
	}
	if( _bBasic ) {
		_iParts = ( _iLen / SPLIT_LEN );
		for( new i = 0 ; i < _iParts ; i++ ) {
			strins(message,"\n", ( ( i + 1 ) * SPLIT_LEN ) );
		}
	}
	#undef SPLIT_LEN
	return message;
}
static gPM_ShowDialog(playerid,dialogid, extra = -1 ) {
	if( dialogid == DIALOG_PM_MENU ) {
	    g_iDialogEdition{ playerid } = 0;
	    gPM_ClearMessageReceivers( playerid );
		if( gPM_GetNewMessages( g_iUserID[ playerid ] ) ) {
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_TABLIST , ""#COL_ORANGE"gPM  Menu" , ""COL_WHITE"Posteingang\t"#COL_GREEN""#MARK_NEW_MESSAGES""#COL_WHITE"\nPostausgang\t\nNachricht Versenden\t\nBenutzer Suche\t" , "Weiter" , "Schließen" );
		}
		else {
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_TABLIST , ""#COL_ORANGE"gPM  Menu" , ""COL_WHITE"Posteingang\t\nPostausgang\t\nNachricht Versenden\t\nBenutzer Suche\t" , "Weiter" , "Schließen" );
		}
		return 1;
	}
	else if( dialogid == DIALOG_PM_EINGANG ) {
		new
			iNachrichtID,
			sName[ MAX_PLAYER_NAME ],
			iOffset,
			iIndex = 0,
			sTitel[ 64 ],
			iStatus,
			sText[ INPUT_SIZE ],
			sString[ ( 45 + 10 + 8 + 8 ) * MAX_QUERY_RESULTS + 1 + 21 + 60 ],
			iRows;
		format( g_sQuery , sizeof( g_sQuery ) , "SELECT `NachrichtID`,`Name`,`Status`,substr(`Text`,0,%d) as `Text` FROM `Nachricht`,`User` WHERE `EmpfaengerID` = %d AND `SenderID` = `UserID` AND NOT( `Status` & %d ) ORDER BY `NachrichtID` DESC" , INPUT_SIZE, g_iUserID[ playerid ] , MessageStatus_DEL_Empfaenger );
		g_dbrQuery = db_query( g_dbPM , g_sQuery );
		g_sQuery[0] = '\0';
		g_iResults[ playerid ] = db_num_rows( g_dbrQuery );
		if( g_iResults[ playerid ] ) {
			sString[0] = '\0';
			iOffset = g_iPage[ playerid ] * MAX_QUERY_RESULTS;
			if( ( ( g_iPage[ playerid ] * MAX_QUERY_RESULTS ) + MAX_QUERY_RESULTS ) > g_iResults[ playerid ] ) {
			    iRows = g_iResults[ playerid ];
			}
			else {
			    iRows = ( g_iPage[ playerid ] * MAX_QUERY_RESULTS ) + MAX_QUERY_RESULTS;
			}
			if( g_iPage[ playerid ] > 0 ) {
			    #if defined SHOW_PREVIOUS_PAGES
				format( sString , sizeof( sString ) , ""#COL_BLUE_LIGHT"<<"#COL_WHITE" Seite zurück ( %d - %d )\n" , ( iOffset - MAX_QUERY_RESULTS ) + 1 , iOffset );
			    #else
				sString = ""#COL_BLUE_LIGHT"<<"#COL_WHITE" Seite zurück\n";
			    #endif
			}
			for(new i = 0 ; i < iOffset ; i++) {
			    db_next_row( g_dbrQuery );
			}
			format( sString , sizeof( sString ) , ""#COL_ORANGE_LIGHT"Absender\t"#COL_ORANGE_LIGHT"Nachricht\n%s", sString );
			for(new i = iOffset ; i < iRows ; i++) {
				iNachrichtID = db_num_fields( g_dbrQuery , 0);
				db_get_field( g_dbrQuery , 1 , sName , sizeof(sName ) );
				iStatus = db_num_fields( g_dbrQuery , 2);
				db_get_field( g_dbrQuery , 3 , sText , sizeof( sText ) );
				if( iStatus & MessageStatus_Read ) {
				    if( strlen( sText ) > 16 ) {
						format( sString , sizeof( sString ) ,"%s%.20s\t%.16s...\n" , sString , sName , sText );
				    }
				    else {
						format( sString , sizeof( sString ) ,"%s%.20s\t%s\n" , sString , sName , sText );
					}
				}
				else  {
				    if( strlen( sText ) > 16 ) {
						format( sString , sizeof( sString ) , "%s%.20s\t%.16s... "#COL_GREEN""#MARK_NEW_MESSAGES""#COL_WHITE"\n" , sString , sName , sText );
				    }
				    else {
						format( sString , sizeof( sString ) , "%s%.20s\t%s "#COL_GREEN""#MARK_NEW_MESSAGES""#COL_WHITE"\n" , sString , sName , sText );
				    }
				}
				g_iRowUniqueID[ playerid ][ iIndex++ ] = iNachrichtID;
				db_next_row( g_dbrQuery );
			}
			if( iRows < g_iResults[ playerid ] ) {
			    #if defined SHOW_NEXT_PAGES
			    format( sString , sizeof( sString ) ,"%s"#COL_BLUE_LIGHT">> "#COL_WHITE"Nächste Seite ( %d - %d )\t\n" , sString , ( iRows + 1 ) , ( ( iRows + MAX_QUERY_RESULTS ) > g_iResults[ playerid ] ) ? g_iResults[ playerid ] : ( iRows + MAX_QUERY_RESULTS ) );
			    #else
			    strcat( sString ,""#COL_BLUE_LIGHT">> "#COL_WHITE"Nächste Seite\t\n", sizeof( sString ) );
			    #endif
			}
			format( sTitel , sizeof( sTitel ) ,""#COL_ORANGE"gPM  Posteingang ( %d - %d ) / %d " , iOffset + 1, iRows , g_iResults[ playerid ] );
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_TABLIST_HEADERS , sTitel , sString , "Lesen" , "Zurück" );
		}
		else {
			g_iDialogEdition{ playerid } = DIALOG_EDITION_NORMAL;
			ShowPlayerDialog( playerid , DIALOG_PM_EINGANG_EMPTY , DIALOG_STYLE_MSGBOX , ""#COL_ORANGE"gPM  Posteingang" , ""#COL_WHITE"Du hast keine Nachrichten im Eingang!" , "Zurück" , "" );
		}
		db_free_result( g_dbrQuery );
		return 1;
	}
	else if( dialogid == DIALOG_PM_AUSGANG ) {
		new
			iNachrichtID,
			iIndex = 0,
			sName[MAX_PLAYER_NAME],
			iStatus,
			iOffset,
			sTitel[ 64 ],
			sText[ INPUT_SIZE ],
			sString[ ( 45 + 4 + 8 + 8 ) * MAX_QUERY_RESULTS + 1 + 21 + 60 ],
			iRows;
		format(g_sQuery,sizeof(g_sQuery),"SELECT `NachrichtID`,`Name`,`Status`,substr(`Text`,0,%d) as `Text` FROM `Nachricht`,`User` WHERE `SenderID` = %d AND `EmpfaengerID` = `UserID` AND NOT( `Status` & %d ) ORDER BY `NachrichtID` DESC" , INPUT_SIZE, g_iUserID[ playerid ] , MessageStatus_DEL_Sender );
		g_dbrQuery = db_query( g_dbPM , g_sQuery );
		g_sQuery[0] = '\0';
		g_iResults[ playerid ] = db_num_rows( g_dbrQuery );
		if( g_iResults[ playerid ] ) {
			sString[0] = '\0';
			iOffset = g_iPage[ playerid ] * MAX_QUERY_RESULTS;
			if( ( ( g_iPage[ playerid ] * MAX_QUERY_RESULTS ) + MAX_QUERY_RESULTS ) > g_iResults[ playerid ] ) {
			    iRows = g_iResults[ playerid ];
			}
			else {
			    iRows = ( g_iPage[ playerid ] * MAX_QUERY_RESULTS ) + MAX_QUERY_RESULTS;
			}
			if( g_iPage[ playerid ] > 0 ) {
			    #if defined SHOW_PREVIOUS_PAGES
				format( sString , sizeof( sString ) , ""#COL_BLUE_LIGHT"<<"#COL_WHITE" Seite zurück ( %d - %d )\n" , ( iOffset - MAX_QUERY_RESULTS ) + 1, iOffset );
			    #else
				sString = ""#COL_BLUE_LIGHT"<<"#COL_WHITE" Seite zurück\n";
			    #endif
			}
			for(new i = 0 ; i < iOffset ; i++) {
			    db_next_row( g_dbrQuery );
			}
			format( sString , sizeof( sString ) , ""#COL_ORANGE_LIGHT"Empfänger\t"#COL_ORANGE_LIGHT"Nachricht\n%s", sString );
			for(new i = iOffset ; i < iRows ; i++) {
				iNachrichtID = db_num_fields( g_dbrQuery , 0 );
				db_get_field( g_dbrQuery , 1 , sName , sizeof( sName ) );
				iStatus = db_num_fields( g_dbrQuery , 2 );
				db_get_field( g_dbrQuery , 3 , sText , sizeof( sText ) );
				if( iStatus & MessageStatus_Read ) {
				    if( strlen( sText ) > 16 ) {
						format( sString , sizeof( sString ) ,"%s%.20s\t%.16s...\n" , sString , sName , sText );
				    }
				    else {
						format( sString , sizeof( sString ) ,"%s%.20s\t%s\n" , sString , sName , sText );
					}
				}
				else {
				    if( strlen( sText ) > 16 ) {
						format( sString , sizeof( sString ) , "%s%.20s\t%.16s... "#COL_RED""#MARK_UNREAD_MESSAGES""#COL_WHITE"\n" , sString , sName , sText );
				    }
				    else {
						format( sString , sizeof( sString ) , "%s%.20s\t%s "#COL_RED""#MARK_UNREAD_MESSAGES""#COL_WHITE"\n" , sString , sName , sText );
					}
				}
				g_iRowUniqueID[ playerid ][ iIndex++ ] = iNachrichtID;
				db_next_row( g_dbrQuery );
			}
			if( iRows < g_iResults[ playerid ] ) {
			    #if defined SHOW_NEXT_PAGES
			    format( sString , sizeof( sString ) ,"%s"#COL_BLUE_LIGHT">> "#COL_WHITE"Nächste Seite ( %d - %d )\n" , sString , ( iRows + 1 ) , ( ( iRows + MAX_QUERY_RESULTS ) > g_iResults[ playerid ] ) ? g_iResults[ playerid ] : ( iRows + MAX_QUERY_RESULTS ));
			    #else
			    strcat( sString ,""#COL_BLUE_LIGHT">> "#COL_WHITE"Nächste Seite\n", sizeof( sString ) );
			    #endif
			}
			format( sTitel , sizeof( sTitel ) ,""#COL_ORANGE"gPM  Postausgang ( %d - %d ) / %d " , iOffset + 1, iRows , g_iResults[ playerid ] );
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_TABLIST_HEADERS , sTitel , sString , "Lesen" , "Zurück" );
		}
		else {
			g_iDialogEdition{ playerid } = DIALOG_EDITION_NORMAL;
			ShowPlayerDialog( playerid , DIALOG_PM_AUSGANG_EMPTY , DIALOG_STYLE_MSGBOX , ""#COL_ORANGE"gPM  Postausgang" , ""#COL_WHITE"Du hast keine Nachrichten im Ausgang!" , "Zurück" , "" );
		}
		db_free_result( g_dbrQuery );
		return 1;
	}
	else if( ( dialogid == DIALOG_PM_EINGANG_MSG ) || ( dialogid == DIALOG_PM_EINGANG_FILTER_MSG ) ) {
		format( g_sQuery , sizeof( g_sQuery ) , "SELECT `Name`,`Status`, strftime('%s',`Tag`) AS Datum,`Uhrzeit`,`Text` FROM `Nachricht`,`User` WHERE `NachrichtID` = %d AND `UserID` = `SenderID` " , DATE_FORMAT , ( extra & 0xFFFF ) );
		g_dbrQuery = db_query( g_dbPM , g_sQuery );
		g_sQuery[0] = '\0';
		if( db_num_rows( g_dbrQuery ) ) {
	        new
				sTag[ 12 ],
				sTitel[ 32+16+8 ],
				sName[ MAX_PLAYER_NAME ],
				sUhrzeit[ 12 ],
				iStatus,
				sNachricht[ GPM_MAX_STRING ],
				sString[ 256 + ( GPM_MAX_STRING )  ];
			db_get_field( g_dbrQuery , 0 , sName , sizeof( sName ) );
			iStatus = db_num_fields( g_dbrQuery , 1 );
			db_get_field( g_dbrQuery , 2 , sTag , sizeof( sTag ) );
			db_get_field( g_dbrQuery , 3 , sUhrzeit , sizeof( sUhrzeit ) );
			db_get_field( g_dbrQuery , 4 , sNachricht , sizeof( sNachricht ) );
			if( !( iStatus & MessageStatus_Read ) ) {
			    iStatus |= MessageStatus_Read;
				format(g_sQuery,sizeof(g_sQuery),"UPDATE `Nachricht` SET `Status` = %d WHERE NachrichtID = %d" , iStatus , ( extra & 0xFFFF ) );
				db_free_result( db_query( g_dbPM , g_sQuery ) );
				g_sQuery[0] = '\0';
			}
			format( sString , sizeof( sString ) , ""#COL_GREY"Von: "#COL_WHITE"%s\n"#COL_GREY"Datum: "#COL_WHITE"%s %s\n\n"#COL_GREY"Nachricht:"#COL_WHITE"\n%s\n\n" , sName , sTag , sUhrzeit , gPM_StripMessageLines( sNachricht ) );
			if( dialogid == DIALOG_PM_EINGANG_MSG ) {
				format( sTitel , sizeof( sTitel ) , ""#COL_ORANGE"gPM  Posteingang - Nachricht (%d)" , ( ( g_iPage[ playerid ] * MAX_QUERY_RESULTS ) + (( extra >> 16 ) & 0xFFFF )) + 1);
			    g_iUserInput[ playerid ] = extra ;
				ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_MSGBOX , sTitel , sString , "Zurück" , "Löschen" );
			}
			else {
				format( sTitel , sizeof( sTitel ) , ""#COL_ORANGE"gPM  Posteingang - Nachricht" );
				ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_MSGBOX , sTitel , sString , "Zurück" , "" );
			}
		}
		db_free_result( g_dbrQuery );
		return 1;
	}
	else if( ( dialogid == DIALOG_PM_AUSGANG_MSG ) || ( dialogid == DIALOG_PM_AUSGANG_FILTER_MSG ) ) {
		format( g_sQuery , sizeof( g_sQuery ) , "SELECT `Name`,`Status`, strftime('%s',`Tag`) AS Datum,`Uhrzeit`,`Text` FROM `Nachricht`,`User` WHERE `NachrichtID` = %d AND `UserID` = `EmpfaengerID`" , DATE_FORMAT , ( extra & 0xFFFF ) );
		g_dbrQuery = db_query( g_dbPM , g_sQuery );
		g_sQuery[0] = '\0';
		if( db_num_rows( g_dbrQuery ) ) {
			new
				sTag[ 12 ],
				sName[ MAX_PLAYER_NAME ],
				sUhrzeit[ 12 ],
				iStatus,
				sNachricht[ GPM_MAX_STRING ],
				sTitel[ 64 ],
				sString[ 256 +  MAX_INPUT_PAGES * INPUT_SIZE  ];
			db_get_field( g_dbrQuery , 0 , sName , sizeof( sName ) );
			iStatus = db_num_fields( g_dbrQuery , 1 );
			db_get_field( g_dbrQuery , 2 , sTag , sizeof( sTag ) );
			db_get_field( g_dbrQuery , 3 , sUhrzeit , sizeof( sUhrzeit ) );
			db_get_field( g_dbrQuery , 4 , sNachricht , sizeof( sNachricht ) );
			format( sString , sizeof( sString ) , ""#COL_GREY"An: "#COL_WHITE"%s\n"#COL_GREY"Datum: "#COL_WHITE"%s %s\n\n"#COL_GREY"Nachricht:"#COL_WHITE"\n%s\n\n" , sName , sTag , sUhrzeit , gPM_StripMessageLines( sNachricht ) );
			if( !( iStatus & MessageStatus_Read ) ) {
				format( sString , sizeof( sString ) , "%s"#COL_GREY"Status: "#COL_RED"Ungelesen" , sString );
			}
			else {
				format( sString , sizeof( sString ) , "%s"#COL_GREY"Status: "#COL_GREEN"Gelesen" , sString );
			}
			if( dialogid == DIALOG_PM_AUSGANG_MSG ) {
				format( sTitel , sizeof( sTitel ) , ""#COL_ORANGE"gPM  Postausgang - Nachricht (%d)" , ( ( g_iPage[ playerid ] * MAX_QUERY_RESULTS ) + (( extra >> 16 ) & 0xFFFF )) + 1);
			    g_iUserInput[ playerid ] = extra;
				ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_MSGBOX , sTitel , sString , "Zurück" , "Löschen" );
			}
			else {
				format( sTitel , sizeof( sTitel ) , ""#COL_ORANGE"gPM  Postausgang - Nachricht" );
				ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_MSGBOX , sTitel , sString , "Zurück" , "" );
			}
		}
		db_free_result( g_dbrQuery );
		return 1;
	}
	else if( dialogid == DIALOG_PM_SCHREIBEN_USER ) {
		if( extra == -1 ) {
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_INPUT , ""#COL_ORANGE"gPM  Nachricht Versenden - User",""#COL_WHITE"Gib unten den exakten Usernamen ein,\nan den du eine Textnachricht versenden möchtest!\n\n"#COL_ORANGE_LIGHT"Hinweis:"#COL_WHITE" Du kannst später noch mehr Empfänger hinzufügen" , "Weiter" , "Zurück" );
		}
		else if(extra == 0 ) {
			new
				sString[ 310 ];
			strunpack( g_supUserInput , g_sUserInput[ playerid ] );
			format( sString , sizeof( sString ) , ""#COL_WHITE"Der genannte User '"#COL_GREY"%s"#COL_WHITE"' konnte nicht in unserer\nDatenbank gefunden werden.\n\nGib unten den exakten Usernamen ein (Groß- und Kleinschreibung),\nan den du eine Textnachricht versenden möchtest!\n\n"#COL_ORANGE_LIGHT"Hinweis:"#COL_WHITE" Du kannst später noch mehr Empfänger hinzufügen" , g_supUserInput );
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_INPUT , ""#COL_ORANGE"gPM  Nachricht Versenden - User" , sString , "Weiter" , "Zurück" );
		}
		else if( extra == 1 ) {
			ShowPlayerDialog( playerid , DIALOG_PM_SCHREIBEN_USER , DIALOG_STYLE_INPUT , ""#COL_ORANGE"gPM  Nachricht Versenden - User" , ""#COL_WHITE"Du kannst dir selber keine Nachrichten schicken!\n\nGib unten den exakten Usernamen ein,\nan den du eine Textnachricht versenden möchtest!\n\n"#COL_ORANGE_LIGHT"Hinweis:"#COL_WHITE" Du kannst später noch mehr Empfänger hinzufügen" , "Weiter" , "Zurück" );
		}
		return 1;
	}
	else if( dialogid == DIALOG_PM_SCHREIBEN_TEXT ) {
        new
			sString[256 + MAX_INPUT_PAGES * INPUT_SIZE ];
        g_supUserInput[ 0 ] = '\0';
		strunpack( g_supUserInput , g_sUserInput[ playerid ] );
		//
		format(sString,sizeof(sString),""#COL_WHITE"Gib unten in das Feld die Nachricht ein,\ndie du an den User '"#COL_GREY"%s"#COL_WHITE"' versenden möchtest.\nZum Fortfahren klick auf Weiter\n\n( 1 / %d )", g_supUserInput , MAX_INPUT_PAGES );
		if( g_iUserMessageInput{ playerid } ) {
		    if( g_iUsersMessageReceivers{ playerid } > 1 ) {
				format(sString,sizeof(sString),""#COL_WHITE"Gib unten in das Feld die Nachricht ein,\ndie du an den User '"#COL_GREY"%s"#COL_WHITE"' und "#COL_GREY"%d"#COL_WHITE" weitere User\nversenden möchtest.\nZum Fortfahren klick auf Weiter", g_supUserInput , ( g_iUsersMessageReceivers{ playerid } - 1 ) );
		    }
		    else {
				format(sString,sizeof(sString),""#COL_WHITE"Gib unten in das Feld die Nachricht ein,\ndie du an den User '"#COL_GREY"%s"#COL_WHITE"' versenden möchtest.\nZum Fortfahren klick auf Weiter", g_supUserInput );
		    }
			format( sString, sizeof(sString) , "%s\n\nBisheriger Text:\n"#COL_GREY"%s\n\n"#COL_WHITE"( %d / %d )" , sString , gPM_StripMessageLines( gPM_MergeMessages( playerid ) ) , ( g_iUserMessageInput{ playerid } + 1 ) , MAX_INPUT_PAGES );
		}
		ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_INPUT , ""#COL_ORANGE"gPM  Nachricht Versenden - Nachricht" , sString , "Weiter" , "Zurück" );
		return 1;
	}
	else if( dialogid == DIALOG_PM_SCHREIBEN_INFO ) {
	    /*
			An:
	         < Liste >
			Nachricht:
			 < Nachricht >
		*/
		new
		    sHuge[  MAX_MESSAGE_RECEIVERS * ( MAX_PLAYER_NAME + 2 ) + MAX_INPUT_PAGES * INPUT_SIZE + 32 ];
		sHuge = ""#COL_GREY"An:"#COL_WHITE"\n";
		strcat( sHuge , gPM_ListMessageReceivers( playerid , true ) , sizeof( sHuge ));
		format( sHuge, sizeof( sHuge ) ,"%s "#COL_ORANGE"%d "#COL_WHITE"Empfänger\n\n\n"#COL_GREY"Nachricht:"#COL_WHITE"\n", sHuge , g_iUsersMessageReceivers{ playerid } );
		strcat( sHuge , gPM_StripMessageLines( gPM_MergeMessages( playerid ) ), sizeof( sHuge ));
		ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_MSGBOX , ""#COL_ORANGE"gPM  Nachricht Versenden - Information" , sHuge , "Abschicken" , "Zurück" );
	}
	else if( dialogid == DIALOG_PM_SCHREIBEN_VERSENDET ) {
        new
			sString[ 256 ];
        g_supUserInput[ 0 ] = '\0';
		strcat( g_supUserInput , gPM_GetUsername( g_aiUserMessageReceivers[ playerid ][ 0 ] ) , sizeof( g_supUserInput ) );
	    if( g_iUsersMessageReceivers{ playerid } > 1 ) {
			format( sString , sizeof(sString) , ""#COL_WHITE"Deine Nachricht wurde erfolgreich an den User '"#COL_GREY"%s"#COL_WHITE"' und "#COL_GREY"%d"#COL_WHITE" weitere User versendet!\nDu findest sie in deinem Postausgang" , g_supUserInput , ( g_iUsersMessageReceivers{ playerid } - 1 ) );
	    }
	    else {
			format( sString , sizeof(sString) , ""#COL_WHITE"Deine Nachricht wurde erfolgreich an den User '"#COL_GREY"%s"#COL_WHITE"' versendet!\nDu findest sie in deinem Postausgang" , g_supUserInput );
	    }
		ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_MSGBOX , ""#COL_ORANGE"gPM  Nachricht Versenden - Versendet" , sString , "Hauptmenu" , "" );
		return 1;
	}
	else if( dialogid == DIALOG_PM_USER_UEBERSICHT ) {
		if( extra == -1 ) {
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_INPUT , ""#COL_ORANGE"gPM   Benutzer Suche" , ""#COL_WHITE"Du kannst einen User suchen, indem du unten in das\ndas Feld seinen Namen eingibst" , "Suchen" , "Zurück" );
	    }
	    else if( extra == 0 ) {
	        new
				sString[ 256 ];
			strunpack( g_supUserInput , g_sUserInput[ playerid ] );
			format( sString , sizeof( sString ) , ""#COL_WHITE"Es wurden keine User mit dem Suchkriterium '"#COL_GREY"%s"#COL_WHITE"' gefunden.\n\nDu kannst einen User suchen, indem du unten in \ndas Feld seinen Namen eingibst" , g_supUserInput );
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_INPUT , ""#COL_ORANGE"gPM  Benutzer Suche" , sString , "Suchen" , "Zurück" );
	    }
	    else if( extra == 1 ) {
	        new
				sString[ 256 ];
			strunpack( g_supUserInput , g_sUserInput[ playerid ] );
			format( sString , sizeof( sString ) , ""#COL_WHITE"Es wurden zu viele User über das Suchkriterium '"COL_GREY"%s"#COL_WHITE"' gefunden.\nDu kannst einen User suchen, indem du unten in \ndas Feld seinen Namen eingibst." , g_supUserInput );
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_INPUT , ""#COL_ORANGE"gPM  Benutzer Suche" , sString , "Suchen" , "Zurück" );
	    }
	    else if( extra == 2 ) {
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_INPUT , ""#COL_ORANGE"gPM  Benutzer Suche" , ""#COL_WHITE"Deine Eingabe war zu kurz oder nicht vorhanden!\n\nDu kannst einen User suchen, indem du unten in das\ndas Feld seinen Namen eingibst" , "Suchen" , "Zurück" );
	    }
		return 1;
	}
	else if( dialogid == DIALOG_PM_USER_UEBERSICHT_QUERY ) {
	    new
			sString[ MAX_PLAYER_NAME * MAX_QUERY_RESULTS ],
			sTitel[ 64 ],
			sName[ MAX_PLAYER_NAME ],
			iRows;
		g_dbrQuery = DBResult:extra;
		iRows = db_num_rows( g_dbrQuery );
		format( sString , sizeof(sString) , ""#COL_ORANGE_LIGHT"Filter '%s' (%d)\n", g_supUserInput , iRows );
		for(new i = 0 ; i < iRows ; i++) {
			g_iRowUniqueID[ playerid ][ i ] = db_num_fields( g_dbrQuery , 0 );
			db_get_field( g_dbrQuery , 1 , sName , sizeof( sName ) );
			format( sString  , sizeof(sString) , "%s%s\n" , sString , sName );
			db_next_row( g_dbrQuery );
		}
		strunpack( g_supUserInput , g_sUserInput[ playerid ] );
		format( sTitel , sizeof( sTitel ) , ""#COL_ORANGE"gPM Nachricht  Benutzer Suche" );
		if( g_iDialogEdition{ playerid } == DIALOG_EDITION_NORMAL ) {
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_TABLIST_HEADERS , sTitel , sString , "Verarbeitung" , "Zurück" );
		}
		else if( g_iDialogEdition{ playerid } == DIALOG_EDITION_ADD_EMPFAENGER ) {
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_TABLIST_HEADERS , sTitel , sString , "Hinzufügen" , "Zurück" );
		}
		db_free_result( g_dbrQuery );
		return 1;
	}
	else if( dialogid == DIALOG_PM_USER_VERARBEITUNG ) {
	    new
	        sString[ 128 ],
			sTitel[ 80 ];
		strunpack( g_supUserInput , g_sUserInput[ playerid ] );
		format( sTitel , sizeof( sTitel ) , ""#COL_ORANGE"gPM Nachricht  Benutzer Suche" );
		format( sString, sizeof( sString ) , ""#COL_ORANGE_LIGHT"Verarbeitung '%s'\nPosteingang\nPostausgang\nNachricht Senden", g_supUserInput );
		ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_TABLIST_HEADERS , sTitel , sString , "Durchführen" , "Zurück" );
	}
	else if( dialogid == DIALOG_PM_SCHREIBEN_MENU ) {
	    new
	        style,
	        sListtext[ 140 ];
		/*
	    if( g_iUserMessageInput[ playerid ] == 0 ) {
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_LIST , ""#COL_ORANGE"gPM  Nachricht Versenden - Menu" , "Versenden\n"#COL_RED"Schreiben fortsetzen\n" , "Weiter" , "Zurück" );
	    }
	    */
        if( g_iUsersMessageReceivers{ playerid } < 1 ) {
	        style = DIALOG_STYLE_TABLIST_HEADERS;
	        format( sListtext , sizeof( sListtext ) , ""#COL_RED"Versenden nicht möglich. Keine Empfänger\n" );
		}
		else {
	        style = DIALOG_STYLE_LIST;
		}
        format( sListtext , sizeof( sListtext ) , "%sVersenden\n" , sListtext );
	    if( g_iUserMessageInput{ playerid } >= MAX_INPUT_PAGES ) {
	        format( sListtext , sizeof( sListtext ) , "%s"#COL_RED"Schreiben fortsetzen\n",sListtext);
		}
	    else {
	        format( sListtext , sizeof( sListtext ) , "%s"#COL_GREEN"Schreiben fortsetzen\n",sListtext);
	    }
        format( sListtext , sizeof( sListtext ) , "%s"#COL_WHITE"Empfänger bearbeiten ("#COL_ORANGE_LIGHT" %d "#COL_WHITE" )\n", sListtext , g_iUsersMessageReceivers{ playerid });
		ShowPlayerDialog( playerid , dialogid , style , ""#COL_ORANGE"gPM  Nachricht Versenden - Menu" , sListtext , "Weiter" , "Zurück" );
	}
	else if( dialogid == DIALOG_PM_EINGANG_ENTF_ABFRAGE ) {
		ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_MSGBOX , ""#COL_ORANGE"gPM  Posteingang - Nachricht Löschen"  , ""#COL_WHITE"Bist du dir sicher,dass du die Nachricht unwiderruflich aus\ndeinem Posteingang löschen willst?\n\n" , "Löschen" , "Zurück" );
	}
	else if( dialogid == DIALOG_PM_EINGANG_ENTF ) {
	    gPM_DeleteMessage( DELETE_MESSAGE_BY_EMPFAENGER , extra );
		ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_MSGBOX , ""#COL_ORANGE"gPM  Posteingang - Nachricht Löschen"  , ""#COL_WHITE"Die Nachricht wurde erfolgreich aus deinem\nPosteingang entfernt." , "Zurück" , "" );
	}
	else if( dialogid == DIALOG_PM_AUSGANG_ENTF_ABFRAGE ) {
		ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_MSGBOX , ""#COL_ORANGE"gPM  Postausgang - Nachricht Löschen"  , ""#COL_WHITE"Bist du dir sicher,dass du die Nachricht unwiderruflich aus\ndeinem Postausgang löschen willst?\n\n" , "Löschen" , "Zurück" );
	}
	else if( dialogid == DIALOG_PM_AUSGANG_ENTF ) {
	    gPM_DeleteMessage( DELETE_MESSAGE_BY_SENDER , extra );
		ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_MSGBOX , ""#COL_ORANGE"gPM  Postausgang - Nachricht Löschen"  , ""#COL_WHITE"Die Nachricht wurde erfolgreich aus deinem\nPostausgang entfernt." , "Zurück" , "" );
	}
	else if( dialogid == DIALOG_PM_EINGANG_FILTER ) {
		new
			iNachrichtID,
			sName[ MAX_PLAYER_NAME ],
			sTitel[ 64 ],
			iStatus,
			sText[ INPUT_SIZE ],
			sString[ ( 45 + 4 + 16 + 40) * MAX_QUERY_RESULTS + 1];
		format( g_sQuery , sizeof( g_sQuery ) , "SELECT `NachrichtID`,`Name`,`Status`,substr(`Text`,0,%d) as `Text`  FROM `Nachricht`,`User` WHERE `EmpfaengerID` = %d AND `SenderID` = %d AND `SenderID` = `UserID` AND NOT( `Status` & %d ) ORDER BY `NachrichtID` DESC LIMIT %d;" , INPUT_SIZE, g_iUserID[ playerid ] , g_iUserInput[ playerid ] , MessageStatus_DEL_Empfaenger , MAX_QUERY_RESULTS);
		g_dbrQuery = db_query( g_dbPM , g_sQuery );
		g_sQuery[0] = '\0';
		g_iResults[ playerid ] = db_num_rows( g_dbrQuery );
		if( g_iResults[ playerid ] ) {
			sString[0] = '\0';
			format( sString , sizeof( sString ) , ""#COL_ORANGE_LIGHT"Absender\t"#COL_ORANGE_LIGHT"Nachricht\n%s", sString );
			for(new i = 0 ; i < g_iResults[ playerid ] ; i++) {
				iNachrichtID = db_num_fields( g_dbrQuery , 0 );
				db_get_field( g_dbrQuery , 1 , sName , sizeof(sName ) );
				iStatus = db_num_fields( g_dbrQuery , 2 );
				db_get_field( g_dbrQuery , 3 , sText , sizeof( sText ) );
				if( iStatus & MessageStatus_Read ) {
				    if( strlen( sText ) > 16 ) {
						format( sString , sizeof( sString ) ,"%s%.20s\t%.16s...\n" , sString , sName , sText );
				    }
				    else {
						format( sString , sizeof( sString ) ,"%s%.20s\t%s\n" , sString , sName , sText );
				    }
				}
				else  {
				    if( strlen( sText ) > 16 ) {
						format( sString , sizeof( sString ) , "%s%.20s\t%.16s... "#COL_GREEN""#MARK_NEW_MESSAGES""#COL_WHITE"\n" , sString , sName , sText );
				    }
				    else {
						format( sString , sizeof( sString ) , "%s%.20s\t%s "#COL_GREEN""#MARK_NEW_MESSAGES""#COL_WHITE"\n" , sString , sName , sText );
				    }
				}
				g_iRowUniqueID[ playerid ][ i ] = iNachrichtID;
				db_next_row( g_dbrQuery );
			}
			g_supUserInput[ 0 ] = '\0';
			strunpack( g_supUserInput , g_sUserInput[ playerid ] );
			format( sTitel , sizeof( sTitel ) ,""#COL_ORANGE"gPM  Posteingang ( %s ) " , g_supUserInput );
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_TABLIST_HEADERS , sTitel , sString , "Lesen" , "Zurück" );
		}
		else {
			g_iDialogEdition{ playerid } = DIALOG_EDITION_FILTER;
		    format( sString , sizeof(sString) , ""#COL_WHITE"In deinem Posteingang befindet sich keine Nachricht\nvom Benutzer "#COL_GREY"%s"#COL_WHITE".", gPM_GetUsername( g_iUserInput[ playerid ] ) );
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_MSGBOX , ""#COL_ORANGE"gPM  Posteingang" , sString, "Zurück" , "" );
		}
		db_free_result( g_dbrQuery );
		return 1;
	}
	else if( dialogid == DIALOG_PM_AUSGANG_FILTER ) {
		new
			iNachrichtID,
			sName[MAX_PLAYER_NAME],
			iStatus,
			sTitel[ 64 ],
			sText[ INPUT_SIZE ],
			sString[ ( 45 + 10 + 16 + 4 + 40) * MAX_QUERY_RESULTS + 1];
		format(g_sQuery,sizeof(g_sQuery),"SELECT `NachrichtID`,`Name`,`Status`,substr(`Text`,0,%d) as `Text`  FROM `Nachricht`,`User` WHERE `SenderID` = %d AND `EmpfaengerID` = %d AND `EmpfaengerID` = `UserID` AND NOT( `Status` & %d ) ORDER BY `NachrichtID` DESC LIMIT %d;" , INPUT_SIZE, g_iUserID[ playerid ] , g_iUserInput[ playerid ] , MessageStatus_DEL_Sender , MAX_QUERY_RESULTS);
		g_dbrQuery = db_query( g_dbPM , g_sQuery );
		g_sQuery[0] = '\0';
		g_iResults[ playerid ] = db_num_rows( g_dbrQuery );
		if( g_iResults[ playerid ] ) {
			sString[0] = '\0';
			format( sString , sizeof( sString ) , ""#COL_ORANGE_LIGHT"Empfänger\t"#COL_ORANGE_LIGHT"Nachricht\n%s", sString );
			for(new i = 0 ; i < g_iResults[ playerid ] ; i++) {
				iNachrichtID = db_num_fields( g_dbrQuery , 0 );
				db_get_field( g_dbrQuery , 1 , sName , sizeof( sName ) );
				iStatus = db_num_fields( g_dbrQuery , 2 );
				db_get_field( g_dbrQuery , 3 , sText , sizeof( sText ) );
				if( iStatus & MessageStatus_Read ) {
				    if( strlen( sText ) > 16 ) {
						format( sString , sizeof( sString ) ,"%s%.20s\t%.16s...\n" , sString , sName , sText );
				    }
				    else {
						format( sString , sizeof( sString ) ,"%s%.20s\t%s\n" , sString , sName , sText );
				    }
				}
				else {
				    if( strlen( sText ) > 16 ) {
						format( sString , sizeof( sString ) , "%s%.20s\t%.16s... "#COL_RED""#MARK_UNREAD_MESSAGES""#COL_WHITE"\n" , sString , sName , sText );
				    }
				    else {
						format( sString , sizeof( sString ) , "%s%.20s\t%s "#COL_RED""#MARK_UNREAD_MESSAGES""#COL_WHITE"\n" , sString , sName , sText );
				    }
				}
				g_iRowUniqueID[ playerid ][ i ] = iNachrichtID;
				db_next_row( g_dbrQuery );
			}
			g_supUserInput[ 0 ] = '\0';
			strunpack( g_supUserInput , g_sUserInput[ playerid ] );
			format( sTitel , sizeof( sTitel ) , ""#COL_ORANGE"gPM  Postausgang ( %s )" , g_supUserInput);
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_TABLIST_HEADERS , sTitel , sString , "Lesen" , "Zurück" );
		}
		else {
			g_iDialogEdition{ playerid } = DIALOG_EDITION_FILTER;
		    format( sString , sizeof(sString) , ""#COL_WHITE"In deinem Postausgang befindet sich keine Nachricht,\ndie an den Benutzer " #COL_GREY "'%s'" #COL_WHITE" versendet wurde.", gPM_GetUsername( g_iUserInput[ playerid ] ) );
			ShowPlayerDialog( playerid , DIALOG_PM_AUSGANG_EMPTY , DIALOG_STYLE_MSGBOX , ""#COL_ORANGE"gPM  Postausgang" , sString , "Zurück" , "" );
		}
		db_free_result( g_dbrQuery );
		return 1;
	}
	else if( dialogid == DIALOG_PM_SCHREIBEN_EMPF_EDIT ) {
	    new
	        style = DIALOG_STYLE_LIST,
	        sTitel[ 64 ],
	        sListtext[ ( MAX_MESSAGE_RECEIVERS * ( MAX_PLAYER_NAME + 2 ) ) + 32 + 30 ];
		if( extra == USERNAME_ALREADY_IN ) {
		    style = DIALOG_STYLE_TABLIST_HEADERS;
		    g_supUserInput[0] = '\0';
			strunpack( g_supUserInput , g_sUserInput[ playerid ] );
	        format( sListtext , sizeof(sListtext) , ""#COL_RED_LIGHT"'%s' bereits als Empfänger in der Liste\n" , g_supUserInput );
		}
		else if( extra == USERNAME_ADDED ) {
		    style = DIALOG_STYLE_TABLIST_HEADERS;
		    g_supUserInput[0] = '\0';
			strunpack( g_supUserInput , g_sUserInput[ playerid ] );
	        format( sListtext , sizeof(sListtext) , ""#COL_GREEN_LIGHT"'%s' als Empfänger hinzugefügt\n" , g_supUserInput );
		}
		else if( extra == USERNAME_REMOVED ) {
		    style = DIALOG_STYLE_TABLIST_HEADERS;
		    g_supUserInput[0] = '\0';
			strunpack( g_supUserInput , g_sUserInput[ playerid ] );
	        format( sListtext , sizeof(sListtext) , ""#COL_RED_LIGHT"'%s' als Empfänger entfernt\n" , g_supUserInput );
		}
        format( sListtext , sizeof(sListtext) , "%s"#COL_BLUE_LIGHT"<<"#COL_WHITE" Zurück\n" , sListtext );
		strcat( sListtext , gPM_ListMessageReceivers( playerid ) , sizeof( sListtext ) );
		if( g_iUsersMessageReceivers{ playerid } >= MAX_MESSAGE_RECEIVERS ) {
		    format( sListtext , sizeof(sListtext) , "%s"#COL_RED"Empfänger hinzufügen\n" , sListtext );
		}
		else {
		    format( sListtext , sizeof(sListtext) , "%s"#COL_GREEN"Empfänger hinzufügen\n" , sListtext );
		}
		g_iDialogEdition{ playerid } = DIALOG_EDITION_ADD_EMPFAENGER;
		format( sTitel , sizeof( sTitel ) , ""#COL_ORANGE"gPM  Empfänger bearbeiten ( %d / "#MAX_MESSAGE_RECEIVERS" )" , g_iUsersMessageReceivers{ playerid } );
		ShowPlayerDialog( playerid , dialogid , style , sTitel , sListtext , "Weiter" , "Löschen" );
	}
	return 1;
}

gPM_OnDialogResponse( playerid, dialogid , response , listitem , inputtext[] ) {
	if( g_dbPM ) {
		if( dialogid == DIALOG_PM_MENU ) {
			if(response) {
				switch(listitem) {
					case 0: gPM_ShowDialog( playerid , DIALOG_PM_EINGANG );
					case 1: gPM_ShowDialog( playerid , DIALOG_PM_AUSGANG );
					case 2: gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_USER );
					case 3: gPM_ShowDialog( playerid , DIALOG_PM_USER_UEBERSICHT );
				}
			}
		}
		else if( dialogid == DIALOG_PM_EINGANG ) {
			if( response ) {
			    if( g_iPage[ playerid ] > 0 ) {
				    if( listitem == MAX_QUERY_RESULTS + 1 ) {
						g_iPage[ playerid ]++;
						return gPM_ShowDialog( playerid , DIALOG_PM_EINGANG );
				    }
				    else if( listitem == 0 ){
						if( g_iPage[ playerid ] > 0 ) {
							g_iPage[ playerid ]--;
							return gPM_ShowDialog( playerid , DIALOG_PM_EINGANG );
						}
					}
					else {
						return gPM_ShowDialog( playerid , DIALOG_PM_EINGANG_MSG , ( g_iRowUniqueID[ playerid ][ listitem - 1] | ( listitem - 1 ) << 16 ) );
					}
			    }
			    else {
				    if( listitem == MAX_QUERY_RESULTS ) {
						g_iPage[ playerid ]++;
						return gPM_ShowDialog( playerid , DIALOG_PM_EINGANG );
				    }
				    else {
						return gPM_ShowDialog( playerid , DIALOG_PM_EINGANG_MSG , ( g_iRowUniqueID[ playerid ][ listitem ] | ( listitem << 16 ) ) );
				    }
			    }
			}
			else {
				g_iPage[ playerid ] = 0;
				return gPM_ShowDialog( playerid , DIALOG_PM_MENU );
			}
		}
		else if( dialogid == DIALOG_PM_EINGANG_MSG ) {
		    if(response) {
				return gPM_ShowDialog( playerid , DIALOG_PM_EINGANG );
		    }
		    else {
				return gPM_ShowDialog( playerid , DIALOG_PM_EINGANG_ENTF_ABFRAGE );
		    }
		}
		else if( dialogid == DIALOG_PM_EINGANG_ENTF_ABFRAGE ) {
		    if(response) {
				return gPM_ShowDialog( playerid , DIALOG_PM_EINGANG_ENTF , ( g_iUserInput[ playerid ] & 0xFFFF ) );
		    }
		    else {
				return gPM_ShowDialog( playerid , DIALOG_PM_EINGANG_MSG , g_iUserInput[ playerid ] );
		    }
		}
		else if( dialogid == DIALOG_PM_EINGANG_ENTF ) {
		    g_iPage[ playerid ] = 0;
			return gPM_ShowDialog( playerid , DIALOG_PM_EINGANG );
		}
		else if( dialogid == DIALOG_PM_AUSGANG ) {
			if( response ) {
			    if( g_iPage[ playerid ] > 0 ) {
				    if( listitem == MAX_QUERY_RESULTS + 1 ) {
						g_iPage[ playerid ]++;
						return gPM_ShowDialog( playerid , DIALOG_PM_AUSGANG );
				    }
				    else if( listitem == 0 ){
						if( g_iPage[ playerid ] > 0 ) {
							g_iPage[ playerid ]--;
							return gPM_ShowDialog( playerid , DIALOG_PM_AUSGANG );
						}
					}
					else {
						return gPM_ShowDialog( playerid , DIALOG_PM_AUSGANG_MSG , ( g_iRowUniqueID[ playerid ][ listitem - 1] | ( listitem - 1 ) << 16 ) );
					}
			    }
			    else {
				    if( listitem == MAX_QUERY_RESULTS ) {
						g_iPage[ playerid ]++;
						return gPM_ShowDialog( playerid , DIALOG_PM_AUSGANG );
				    }
				    else {
						return gPM_ShowDialog( playerid , DIALOG_PM_AUSGANG_MSG , ( g_iRowUniqueID[ playerid ][ listitem ] | ( listitem << 16 ) ) );
				    }
			    }
			}
			else {
				g_iPage[ playerid ] = 0;
				return gPM_ShowDialog( playerid , DIALOG_PM_MENU );
			}
		}
		else if( dialogid == DIALOG_PM_AUSGANG_MSG ) {
		    if(response) {
				return gPM_ShowDialog( playerid , DIALOG_PM_AUSGANG );
		    }
		    else {
				return gPM_ShowDialog( playerid , DIALOG_PM_AUSGANG_ENTF_ABFRAGE );
		    }
		}
		else if( dialogid == DIALOG_PM_AUSGANG_ENTF_ABFRAGE ) {
		    if(response) {
				return gPM_ShowDialog( playerid , DIALOG_PM_AUSGANG_ENTF , ( g_iUserInput[ playerid ] & 0xFFFF ) );
		    }
		    else {
				return gPM_ShowDialog( playerid , DIALOG_PM_AUSGANG_MSG , g_iUserInput[ playerid ] );
		    }
		}
		else if( dialogid == DIALOG_PM_AUSGANG_ENTF ) {
		    g_iPage[ playerid ] = 0;
			return gPM_ShowDialog( playerid , DIALOG_PM_AUSGANG );
		}
		else if( dialogid == DIALOG_PM_SCHREIBEN_USER ) {
			if(response) {
				new
					iUserID;
				g_sUserInput[ playerid ][ 0 ] = '\0';
				g_supUserInput[ 0 ] = '\0';
				strcat( g_supUserInput , db_escape( inputtext ) , MAX_PLAYER_NAME );
				strpack( g_sUserInput[ playerid ] , g_supUserInput , MAX_PLAYER_NAME );
				iUserID = gPM_GetUserID( g_supUserInput );
				if( iUserID == INVALID_USER_ID ) {
					return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_USER , 0 );
				}
				else if( iUserID == g_iUserID[ playerid ] ) {
					return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_USER , 1 );
				}
				g_iUserInput[ playerid ] = iUserID;
				gPM_AddMessageReceiver( playerid , iUserID );
				g_iUserMessageInput{ playerid } = 0;
				g_iDialogEdition{ playerid } = DIALOG_EDITION_NORMAL;
				return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_TEXT );
			}
			else {
				return gPM_ShowDialog( playerid , DIALOG_PM_MENU );
			}
		}
		else if( dialogid == DIALOG_PM_SCHREIBEN_TEXT ) {
			if(response) {
			    if( !inputtext[0] ) {
			        return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_TEXT );
				}
				g_supMessageSingleInput[ 0 ] = '\0';
				strcat( g_supMessageSingleInput , db_escape( inputtext ) );
				g_sUserMessageInput[ playerid ][ g_iUserMessageInput{ playerid } ][ 0 ] = '\0';
				strpack( g_sUserMessageInput[ playerid ][ g_iUserMessageInput{ playerid }++ ] , g_supMessageSingleInput);
				return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_MENU );
			}
			else {
			    if( g_iUserMessageInput{ playerid } >= 1 ) {
					return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_MENU );
			    }
			    //
			    if( g_iDialogEdition{ playerid } == DIALOG_EDITION_NORMAL ) {
						return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_USER );
			    }
			    else if( g_iDialogEdition{ playerid } == DIALOG_EDITION_FILTER ) {
					return gPM_ShowDialog( playerid , DIALOG_PM_USER_VERARBEITUNG );
			    }
			}
		}
		else if( dialogid == DIALOG_PM_SCHREIBEN_VERSENDET ) {
			return gPM_ShowDialog( playerid , DIALOG_PM_MENU );
		}
		else if( dialogid == DIALOG_PM_USER_UEBERSICHT ) {
			if(response) {
			    new
			        iRows;
				if( strlen(inputtext) < 2 ) {
					return gPM_ShowDialog( playerid , DIALOG_PM_USER_UEBERSICHT , 2 );
				}
				g_sUserInput[ playerid ][ 0 ] = '\0';
				g_supUserInput[ 0 ] = '\0';
				strcat( g_supUserInput, db_escape( inputtext ) , MAX_PLAYER_NAME );
				strpack( g_sUserInput[ playerid ] , g_supUserInput , MAX_PLAYER_NAME );
				gPM_FilterUsernames( g_iUserID[ playerid ] , g_supUserInput , g_dbrQuery );
				iRows = db_num_rows( g_dbrQuery );
				if( iRows == 0 ) {
					db_free_result( g_dbrQuery );
					return gPM_ShowDialog( playerid , DIALOG_PM_USER_UEBERSICHT , 0 );
				}
				else if( iRows > MAX_QUERY_RESULTS ) {
					db_free_result( g_dbrQuery );
					return gPM_ShowDialog( playerid , DIALOG_PM_USER_UEBERSICHT , 1 );
			    }
				return gPM_ShowDialog( playerid , DIALOG_PM_USER_UEBERSICHT_QUERY , _:g_dbrQuery );
			}
			else {
			    if( g_iDialogEdition{ playerid } == DIALOG_EDITION_ADD_EMPFAENGER ) {
					return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_MENU );
			    }
			    else if( g_iDialogEdition{ playerid } == DIALOG_EDITION_NORMAL ) {
					return gPM_ShowDialog( playerid , DIALOG_PM_MENU );
			    }
			}
		}
		else if( dialogid == DIALOG_PM_USER_UEBERSICHT_QUERY ) {
		    if( response ) {
				g_sUserInput[ playerid ][ 0 ] = '\0';
				g_supUserInput[ 0 ] = '\0';
				strcat( g_supUserInput, inputtext , MAX_PLAYER_NAME );
				strpack( g_sUserInput[ playerid ] , g_supUserInput , MAX_PLAYER_NAME );
				g_iUserInput[ playerid ] = gPM_GetUserID( g_supUserInput );
				if( g_iDialogEdition{ playerid } == DIALOG_EDITION_NORMAL ) {
					return gPM_ShowDialog( playerid , DIALOG_PM_USER_VERARBEITUNG );
				}
				else if( g_iDialogEdition{ playerid } == DIALOG_EDITION_ADD_EMPFAENGER ) {
				    new
						extra = gPM_AddMessageReceiver( playerid , g_iUserInput[ playerid ] );
					return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_EMPF_EDIT , extra);
				}
		    }
		    else {
				return gPM_ShowDialog( playerid , DIALOG_PM_USER_UEBERSICHT );
		    }
		}
		else if ( dialogid == DIALOG_PM_EINGANG_EMPTY ) {
			if( g_iDialogEdition{ playerid } == DIALOG_EDITION_NORMAL ) {
				return gPM_ShowDialog( playerid , DIALOG_PM_MENU );
			}
			else if( g_iDialogEdition{ playerid } == DIALOG_EDITION_FILTER ) {
				return gPM_ShowDialog( playerid , DIALOG_PM_USER_VERARBEITUNG );
			}
		}
		else if ( dialogid == DIALOG_PM_AUSGANG_EMPTY ) {
			if( g_iDialogEdition{ playerid } == DIALOG_EDITION_NORMAL ) {
				return gPM_ShowDialog( playerid , DIALOG_PM_MENU );
			}
			else if( g_iDialogEdition{ playerid } == DIALOG_EDITION_FILTER ) {
				return gPM_ShowDialog( playerid , DIALOG_PM_USER_VERARBEITUNG );
			}
		}
		else if( dialogid == DIALOG_PM_USER_VERARBEITUNG ) {
		    if(response) {
				switch( listitem ) {
				    case 0: {
				        return gPM_ShowDialog( playerid , DIALOG_PM_EINGANG_FILTER);
				    }
				    case 1: {
				        return gPM_ShowDialog( playerid , DIALOG_PM_AUSGANG_FILTER);
				    }
				    case 2: {
				        g_iUserMessageInput{ playerid } = 0;
				        g_iDialogEdition{ playerid } = DIALOG_EDITION_FILTER;
				        gPM_AddMessageReceiver( playerid , g_iUserInput[ playerid ] );
				        return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_TEXT );
				    }
				}
		    }
		    else {
				return gPM_ShowDialog( playerid , DIALOG_PM_MENU );
		    }
		}
		else if( dialogid == DIALOG_PM_SCHREIBEN_INFO ) {
		    if(response) {
		        gPM_MergeMessages( playerid ); // -> g_supMessageInput
				gPM_SendMessageArray( g_iUserID[ playerid ] , g_aiUserMessageReceivers[ playerid ] , g_supMessageInput , g_iUsersMessageReceivers{ playerid } );
		        return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_VERSENDET );
		    }
		    else {
		        return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_MENU );
		    }
		}
		else if( dialogid == DIALOG_PM_SCHREIBEN_MENU ) {
		    if(response) {
				switch( listitem ) {
				    case 0: {
				        if( g_iUsersMessageReceivers{ playerid } < 1 ) {
					        return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_MENU , 0);
				        }
				        return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_INFO );
				    }
				    case 1: {
				        if( g_iUserMessageInput{ playerid } >= MAX_INPUT_PAGES ) {
					        return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_MENU );
				        }
				        else {
					        return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_TEXT );
				        }
				    }
				    case 2: {
				        return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_EMPF_EDIT );
				    }
				}
		    }
		    else {
		        if( g_iDialogEdition{ playerid } == DIALOG_EDITION_FILTER ) {
			        return gPM_ShowDialog( playerid , DIALOG_PM_USER_VERARBEITUNG );
		        }
		        else {
			        return gPM_ShowDialog( playerid , DIALOG_PM_MENU );
		        }
		    }
		}
		else if( dialogid == DIALOG_PM_EINGANG_FILTER ) {
		    if(response) {
		        if( listitem != INVALID_LIST_ITEM ) {
			        return gPM_ShowDialog( playerid , DIALOG_PM_EINGANG_FILTER_MSG , g_iRowUniqueID[ playerid ][ listitem ] );
		        }
		    }
	        return gPM_ShowDialog( playerid , DIALOG_PM_USER_VERARBEITUNG );
		}
		else if( dialogid == DIALOG_PM_AUSGANG_FILTER ) {
		    if(response) {
		        if( listitem != INVALID_LIST_ITEM ) {
			        return gPM_ShowDialog( playerid , DIALOG_PM_AUSGANG_FILTER_MSG , g_iRowUniqueID[ playerid ][ listitem ] );
				}
		    }
	        return gPM_ShowDialog( playerid , DIALOG_PM_USER_VERARBEITUNG );
		}
		else if( dialogid == DIALOG_PM_AUSGANG_FILTER_MSG ) {
		    return gPM_ShowDialog( playerid , DIALOG_PM_AUSGANG_FILTER );
		}
		else if( dialogid == DIALOG_PM_EINGANG_FILTER_MSG ) {
		    return gPM_ShowDialog( playerid , DIALOG_PM_EINGANG_FILTER );
		}
		else if( dialogid == DIALOG_PM_SCHREIBEN_EMPF_EDIT ) {
		    if(response) {
		        if( listitem == 0 ) {
		            return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_MENU );
		        }
		        else if( listitem == g_iUsersMessageReceivers{ playerid } + 1 ) {
					if( g_iUsersMessageReceivers{ playerid } >= MAX_MESSAGE_RECEIVERS ) {
			            return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_EMPF_EDIT );
					}
					else {
			            return gPM_ShowDialog( playerid , DIALOG_PM_USER_UEBERSICHT );
					}
		        }
		        else {
		            return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_EMPF_EDIT );
		        }
		    }
		    else {
		        if( 0 < listitem < ( g_iUsersMessageReceivers{ playerid } + 1 ) ) {
					new
						extra = gPM_RemoveMessageReceiver( playerid , gPM_GetUserID( inputtext ) );
					g_sUserInput[ playerid ][ 0 ] = '\0';
					g_supUserInput[ 0 ] = '\0';
					strcat( g_supUserInput, inputtext , MAX_PLAYER_NAME );
					strpack( g_sUserInput[ playerid ] , g_supUserInput , MAX_PLAYER_NAME );
		            return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_EMPF_EDIT , extra );
		        }
		        else {
		            return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_MENU );
		        }
		    }
		}
	}
	return 0;
}

gPM_Show(playerid) {
	if( g_dbPM ) {
		if( g_iLoggedIn{ playerid } == 0 ) {
		    new
		        sString[ 128 ];
			GetPlayerName(playerid, sString , sizeof( sString ) );
			format( sString , sizeof( sString ) , "* gPM: Du bist nicht als Benutzer '%s' angemeldet." , sString );
		    SendClientMessage( playerid , COLOR_RED , sString);
		    return 1;
		}
		return gPM_ShowDialog( playerid , DIALOG_PM_MENU );
	}
	return 0;
}

forward gPM_OnLogin(playerid);
public gPM_OnLogin(playerid) {
	if( g_dbPM ) {
		if( 0 <= playerid < MAX_PLAYERS ) {
			new
			    iNewMessages;
			iNewMessages = gPM_GetNewMessages( g_iUserID[ playerid ] );
			if( iNewMessages ) {
				new
					sString[ 75 ];
				format( sString , sizeof( sString ) , "* gPM: Du hast %d ungelese Nachrichten in deinem Posteingang! ( /gpm )" , iNewMessages );
				SendClientMessage( playerid , COLOR_WHITE , sString );
			}
			g_iLoggedIn{ playerid } = 1;
			return 1;
		}
	}
	return 0;
}

stock gPM_AddUsers(const file[]) {
	new
		_sTmp[ MAX_PLAYER_NAME + 5 ],
		File:fFile;
	fFile = fopen( file , io_read );
	if( fFile ) {
		db_free_result( db_query( g_dbPM , "BEGIN" ) );
		while( fread( fFile , _sTmp , sizeof( _sTmp ) ) ) {
			StripNewLine( _sTmp );
			if( gPM_GetUserID( _sTmp ) == INVALID_USER_ID ) {
				gPM_AddUsername( _sTmp );
			}
		}
		fclose( fFile );
		db_free_result( db_query( g_dbPM , "COMMIT" ) );
		return 1;
	}
	return 0;
}

stock StripNewLine(str[]) //ysi_misc.own
{
	new
		l = strlen(str);
	while (l-- && str[l] <= ' ') str[l] = '\0';
}

static gPM_FilterUsernames( my_userid , const username_filter[] , &DBResult:dbr ) {
	format( g_sQuery , sizeof( g_sQuery ) , "SELECT * FROM `User` WHERE `Name` LIKE '%%%s%%' AND NOT(`UserID` = %d) ORDER BY `Name` ASC" , username_filter , my_userid );
	dbr = db_query( g_dbPM , g_sQuery );
	g_sQuery[0] = '\0';
	if( dbr ) {
		return 1;
	}
	return 0;
}

static gPM_GetUsers() {
	new
		iUsers;
	g_dbrQuery = db_query( g_dbPM , "SELECT COUNT(*) FROM `User`" );
	iUsers = db_num_fields( g_dbrQuery , 0 );
    db_free_result( g_dbrQuery );
	return iUsers;
}

static gPM_GetNachrichten() {
	new
		iNachrichten;
	g_dbrQuery = db_query( g_dbPM , "SELECT COUNT(*) FROM `Nachricht`" );
	iNachrichten = db_num_fields( g_dbrQuery , 0 );
	db_free_result( g_dbrQuery );
	return iNachrichten;
}

static gPM_GetUsername( userid ) {
	new
		sUsername[ MAX_PLAYER_NAME ] = "INVALID_USERNAME";
	format( g_sQuery , sizeof( g_sQuery ) , "SELECT `Name` FROM `User` WHERE `UserID` = %d" , userid );
	g_dbrQuery = db_query( g_dbPM , g_sQuery );
	if( db_num_rows( g_dbrQuery ) ) {
		db_get_field( g_dbrQuery , 0 , sUsername , sizeof( sUsername ) );
	}
	g_sQuery[0] = '\0';
	db_free_result( g_dbrQuery );
	return sUsername;
}

#define MAX_INI_ENTRY_TEXT INPUT_SIZE
stock db_escape(text[]) // Y_LESS
{
	new
		ret[MAX_INI_ENTRY_TEXT * 2],
		ch,
		i,
		j;
	while ((ch = text[i++]) && j < sizeof (ret))
	{
		if (ch == '\'')
		{
			if (j < sizeof (ret) - 2)
			{
				ret[j++] = '\'';
				ret[j++] = '\'';
			}
		}
		else if (j < sizeof (ret))
		{
			ret[j++] = ch;
		}
		else
		{
			j++;
		}
	}
	ret[sizeof (ret) - 1] = '\0';
	return ret;
}
static gPM_MergeMessages( playerid ) {
    g_supMessageSingleInput[ 0 ] = '\0';
    g_supMessageInput[ 0 ] = '\0';
	for(new i = 0 ; i < g_iUserMessageInput{ playerid } ; i++) {
	    strunpack( g_supMessageSingleInput , g_sUserMessageInput[ playerid ][ i ] );
		strcat( g_supMessageInput , g_supMessageSingleInput );
	}
	return g_supMessageInput;
}

static gPM_ClearMessageReceivers( playerid ) {
	if( g_iUsersMessageReceivers{ playerid } ) {
		for(new i = 0 ; i < MAX_MESSAGE_RECEIVERS ; i++ ) {
		    g_aiUserMessageReceivers[ playerid ][ i ] = INVALID_USER_ID;
		}
		g_iUsersMessageReceivers{ playerid } = 0;
	}
	return 1;
}

static gPM_AddMessageReceiver( playerid , receiverid ) {
	if( g_iUsersMessageReceivers{ playerid } >= MAX_MESSAGE_RECEIVERS ) {
	    return USERNAME_CANT_ADD;
	}
	for( new i = 0 ; i < g_iUsersMessageReceivers{ playerid } ; i++) {
	    if( g_aiUserMessageReceivers[ playerid ][ i ] == receiverid ) {
	        return USERNAME_ALREADY_IN;
	    }
	}
	g_aiUserMessageReceivers[ playerid ][ g_iUsersMessageReceivers{ playerid } ] = receiverid;
    g_iUsersMessageReceivers{ playerid }++;
    return USERNAME_ADDED;
}

static gPM_RemoveMessageReceiver( playerid , receiverid ) {
	for( new i = 0 ; i < g_iUsersMessageReceivers{ playerid } ; i++) {
	    if( g_aiUserMessageReceivers[ playerid ][ i ] == receiverid ) {
			for(new j = i ; j < g_iUsersMessageReceivers{ playerid } - 1; j++) {
				g_aiUserMessageReceivers[ playerid ][ j ] = g_aiUserMessageReceivers[ playerid ][ j + 1 ];
			}
			break;
	    }
	}
	g_iUsersMessageReceivers{ playerid }--;
	return USERNAME_REMOVED;
}

static gPM_ListMessageReceivers( playerid , bool:bForList = false) {
	new
	    sMessageReceivers[ MAX_MESSAGE_RECEIVERS * ( MAX_PLAYER_NAME + 2 ) ],
	    sUsername[ MAX_PLAYER_NAME ],
	    iNumRows,
		sUserIDs[ MAX_MESSAGE_RECEIVERS * ( 1 + 5 ) ];
    sUserIDs[ 0 ] = '\0';
	sMessageReceivers[ 0 ] = '\0';
	for( new i ; i < g_iUsersMessageReceivers{ playerid } ; i++) {
		if(!i) {
			format( sUserIDs , sizeof( sUserIDs ),"%d", g_aiUserMessageReceivers[ playerid ][ i ] );
		}
		else {
			format( sUserIDs , sizeof( sUserIDs ),"%s,%d", sUserIDs , g_aiUserMessageReceivers[ playerid ][ i ] );
		}
	}
	format( g_sQuery , sizeof( g_sQuery ) , "SELECT `Name` FROM `User` WHERE `UserID` IN(%s)" , sUserIDs );
	g_dbrQuery = db_query( g_dbPM , g_sQuery );
	g_sQuery[0] = '\0';
	iNumRows = db_num_rows( g_dbrQuery );
	if( !bForList ) {
		for(new i = 0 ; i < iNumRows ; i++) {
			db_get_field( g_dbrQuery , 0 , sUsername , sizeof( sUsername ) );
			strcat( sMessageReceivers , sUsername , sizeof( sMessageReceivers ) );
			strcat( sMessageReceivers , "\n" , sizeof( sMessageReceivers ) );
			db_next_row( g_dbrQuery );
		}
	}
	else {
		for(new i = 0 ; i < iNumRows ; i++) {
			strcat( sMessageReceivers , "  " , sizeof( sMessageReceivers ) );
			db_get_field( g_dbrQuery , 0 , sUsername , sizeof( sUsername ) );
			strcat( sMessageReceivers , sUsername , sizeof( sMessageReceivers ) );
			if( i == ( iNumRows - 1 ) ) {
				strcat( sMessageReceivers , "\n" , sizeof( sMessageReceivers ) );
			}
			else {
				strcat( sMessageReceivers , ",\n" , sizeof( sMessageReceivers ) );
			}
			db_next_row( g_dbrQuery );
		}
	}
	db_free_result( g_dbrQuery );
	return sMessageReceivers;
}

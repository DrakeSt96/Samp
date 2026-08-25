#if defined _g_P_M___
* - -
*
*	Projekt:		gPM
*	Lizenz:			GNU Version 3
*	Datei:			gPM.inc
*	Version:		1.3
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
*       1.3 :
*            - Nachricht kann nun an mehrere User gleichzeitig versendet werden
*            - Einfaches hinzufügen / entfernen von Usern für das Versenden
*            - Fehler behoben, dass 'strins' zum Absturz bringt
*            - Nachricht angepasst falls Suchkriterium zu viele Ergebnisse erzeugt
*
*
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
#include </Gloabe Includes/zcmd>

#define DATABASE "NrDatenbank.s3db"

#define MAX_QUERY_RESULTS 20
#define MAX_EINGANG_MESSAGES MAX_QUERY_RESULTS

#define SHOW_NEXT_PAGES
#define SHOW_PREVIOUS_PAGES

// #define PLAY_SOUND
#if defined PLAY_SOUND
	#define INCOMING_MESSAGE_SOUND "www.sa-mp.de/sound.mp3"
#endif
//#define EDIT_MESSAGES

#define INVALID_USERID -1

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
#define COL_GREEN "{00FF00}"
#define COL_RED "{FF0000}"
#define COL_ORANGE "{FF9900}"

#define DATE_FORMAT "%d.%m.%Y"

#define GPM_USERCALL_KEY INVALID_PLAYER_ID
#define GPM_USERCALL_FUNCTION "gPM_UserCall"

#define GPM_MAX_STRING ( MAX_INPUT_PAGES * INPUT_SIZE + 20 )


static
	g_iUserID[ MAX_PLAYERS ],
	g_supUserInput[ MAX_PLAYER_NAME ],
	
	g_supMessageInput[ GPM_MAX_STRING ], // 20 für \n
	g_supMessageSingleInput[ INPUT_SIZE ],
	g_sUserMessageInput[ MAX_PLAYERS ][ MAX_INPUT_PAGES ][ INPUT_SIZE char],
	g_iUserMessageInput[ MAX_PLAYERS char ],
	g_iDialogEdition[ MAX_PLAYERS char],
	
	g_aiUserMessageReceivers[ MAX_PLAYERS ][ MAX_MESSAGE_RECEIVERS ],
	g_iUsersMessageReceivers[ MAX_PLAYERS char],

	g_sUserInput[ MAX_PLAYERS ][ MAX_PLAYER_NAME char ],
	g_iUserInput[ MAX_PLAYERS ],
	g_iRowUniqueID[ MAX_PLAYERS ][ MAX_EINGANG_MESSAGES ],
	
	g_iResults[ MAX_PLAYERS ],
	g_iPage[ MAX_PLAYERS ],

	g_sQuery[ 160  + ( MAX_INPUT_PAGES * INPUT_SIZE )  ],
	DBResult:g_dbrQuery,
	bool:g_bHas_gPMUC = false,
	DB:g_dbPM;
	
	
enum ( <<= 1 ) {
	MessageStatus_Read = 1,
	MessageStatus_DEL_Sender, // del von sender ( postausgang )
	MessageStatus_DEL_Empfaenger // del von empfaenger ( posteingang )
}

enum ( += 1 ) {
	DIALOG_EDITION_NORMAL,
	DIALOG_EDITION_ADD_EMPFAENGER
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

stock gPM_Init() {
	print(" >> gPM FS: Init");
	g_dbPM = db_open( DATABASE );
	for(new i = 0 ; i < MAX_PLAYERS ; i++) {
	    if( IsPlayerConnected( i ) ) {
	        gPM_OnPlayerConnect( i );
	    }
	}
	// gPM_AddUsers("gPM.index"); <-- automatisch eine liste auf Usern hinzufügen
	db_free_result( db_query( g_dbPM , "PRAGMA synchronous = OFF" ) );
	printf("gPM <> Database ID: %d",_:g_dbPM);
	printf("gPM <> Users: %d" , gPM_GetUsers() );
	printf("gPM <> Nachrichten: %d" , gPM_GetNachrichten() );
	g_bHas_gPMUC = CallRemoteFunction( GPM_USERCALL_FUNCTION , "d" , GPM_USERCALL_KEY ) == 1 ? true : false ; // funcidx "boxed"
	if( !g_bHas_gPMUC ) {
		printf("gPM <> Funktion "#GPM_USERCALL_FUNCTION" fehlt oder der Key 0x%04x fehlt! ( %d ) " , funcidx( GPM_USERCALL_FUNCTION ) , GPM_USERCALL_KEY);
		printf("gPM <> Zertifizierung von Useraccount daher nicht aktiviert");
	}
	else {
		printf("gPM <> Zertifizierung von Useraccount aktiviert");
	}
	return 1;
}

stock gPM_Close() {
	print(" >> gPM FS: Close");
	db_close( g_dbPM );
	return 1;
}

stock gPM_AddUsername( username[] ) {
	format( g_sQuery , sizeof( g_sQuery ) , "INSERT INTO `USER` ( `Name`) VALUES ('%s')" , db_escape( username ) );
	db_free_result( db_query( g_dbPM , g_sQuery ) );
	printf("gPM <> Benutzer '%s' hinzugefügt" , username );
	return 1;
}

stock gPM_OnPlayerConnect(playerid) {
	new
		iNewMessages,
		sName[ MAX_PLAYER_NAME ];
	GetPlayerName( playerid , sName , sizeof( sName ) );
	g_iUserID[ playerid ] = gPM_GetUserID( sName );
	g_iResults[ playerid ] = 0;
	g_iPage[ playerid ] = 0;

    if( g_iUserID[playerid] == INVALID_USERID ) {
        new
			sString[ 128+32 ];
		gPM_AddUsername( sName );
		g_iUserID[ playerid ] = gPM_GetUserID( sName );
		format( sString , sizeof( sString ) , "Hey %s, willkommen auf unserem Server. Probier doch unser neues Nachrichten-System aus. <> Diese Nachricht wurde automatisch versendet. <>" , db_escape( sName ) );
		gPM_SendMessage( 1 , g_iUserID[ playerid ] , sString );
    }
	iNewMessages = gPM_GetNewMessages( g_iUserID[ playerid ] );
	if( iNewMessages ) {
		new
			sString[ 70 ];
		format( sString , sizeof( sString ) , "* gPM: Du hast %d ungelese Nachrichten in deinem Posteingang! ( /GPM )" , iNewMessages );
		SendClientMessage( playerid , COLOR_WHITE , sString );
	}
	return 1;
}

stock gPM_OnPlayerDisconnect(playerid, reason ) {
	#pragma unused reason
	g_iUserID[playerid] = INVALID_USERID;
	return 1;
}
stock gPM_GetNewMessages( userid) {
	new
		iRows;
	format( g_sQuery , sizeof( g_sQuery ) , "SELECT * FROM `Nachricht` WHERE `EmpfaengerID` = '%d' AND NOT(`Status` & '%d' )" , userid , MessageStatus_Read );
	g_dbrQuery = db_query( g_dbPM , g_sQuery );
	iRows = db_num_rows( g_dbrQuery );
	db_free_result( g_dbrQuery );
	return iRows;
}

stock gPM_GetUserID( const name[] ) {
	new
		sUserID[8],
		iUserID = INVALID_USERID;
	format( g_sQuery , sizeof( g_sQuery ) , "SELECT `UserID` FROM `USER` WHERE `Name` = '%s'" , name );
	g_dbrQuery = db_query( g_dbPM , g_sQuery );
	if( db_num_rows( g_dbrQuery ) == 1 ) {
		db_get_field( g_dbrQuery , 0 , sUserID , sizeof( sUserID ) );
		iUserID = strval( sUserID );
	}
	db_free_result( g_dbrQuery );
	return iUserID;
}

stock gPM_SendMessage( senderid , receiverid , const message[] ) {
	format( g_sQuery , sizeof( g_sQuery ) , "INSERT INTO `Nachricht` (`SenderID`,`EmpfaengerID`,`Status`,`Tag`,`Uhrzeit`,`Text`) VALUES ('%d','%d','%d', date('now') ,time('now'),'%s')" , senderid , receiverid , 0 , message );
	db_free_result( db_query( g_dbPM , g_sQuery ) );
	for(new i = 0 ; i < MAX_PLAYERS ; i++) {
		if( IsPlayerConnected( i ) ) {
			if( g_iUserID[ i ] == receiverid ) {
				gPM_OnPlayerReceiveMessage( i , senderid , message );
				break;
			}
		}
	}
	return 1;
}

stock gPM_SendMessageArray( senderid , array[ MAX_MESSAGE_RECEIVERS ] , const message[] , count ) {
	new
	    j;
	db_free_result( db_query( g_dbPM , "BEGIN" ) );
	for(new i = 0 ; i < count ; i++ ) {
		format( g_sQuery , sizeof( g_sQuery ) , "INSERT INTO `Nachricht` (`SenderID`,`EmpfaengerID`,`Status`,`Tag`,`Uhrzeit`,`Text`) VALUES ('%d','%d','%d', date('now') ,time('now'),'%s')" , senderid , array[ i ] , 0 , message );
		db_free_result( db_query( g_dbPM , g_sQuery ) );
	}

	db_free_result( db_query( g_dbPM , "COMMIT" ) );
	for(new i = 0 ; i < MAX_PLAYERS ; i++) {
		if( IsPlayerConnected( i ) ) {
		    for( j = 0 ; j < count ; j++ ) {
				if( g_iUserID[ i ] == array[ j ] ) {
					gPM_OnPlayerReceiveMessage( array[ j ] , senderid , message );
					continue;
				}
		    }
		}
	}
	for(new i = 0 ; i < count ; i++) {
	    for( j = 0 ; j < MAX_PLAYERS ; j++) {
	        if( g_iUserID[j] == array[i] ) {
	            gPM_OnPlayerReceiveMessage( j , senderid , " ");
	            break;
	        }
	    }
	}
	return 1;
}

stock gPM_DeleteMessage( typ , messageid) {
	if( typ == DELETE_MESSAGE_BY_SENDER ) {
		format( g_sQuery , sizeof( g_sQuery ) , "UPDATE `Nachricht` SET `Status` = `Status` | '%d' WHERE `NachrichtID` = '%d'" , MessageStatus_DEL_Sender , messageid);
	}
	else if( typ == DELETE_MESSAGE_BY_EMPFAENGER ) {
		format( g_sQuery , sizeof( g_sQuery ) , "UPDATE `Nachricht` SET `Status` = `Status` | '%d' WHERE `NachrichtID` = '%d'" , MessageStatus_DEL_Empfaenger , messageid);
	}
	db_free_result( db_query( g_dbPM , g_sQuery ) );
	return 1;
}

stock gPM_OnPlayerReceiveMessage( playerid , send_userid , const message[] ) {
	#pragma unused message
	new
		sString[ 128 ];
	format( sString , sizeof( sString ) , "* gPM: Du hast eine Nachricht von %s empfangen" , gPM_GetUsername( send_userid ) );
	SendClientMessage( playerid , COLOR_WHITE , sString );
	#if defined PLAY_SOUND
	PlayAudioStreamForPlayer( playerid , INCOMING_MESSAGE_SOUND ); 
	#endif
	return 1;
}

stock gPM_StripMessageLines( message[ GPM_MAX_STRING ] ) {
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
stock gPM_ShowDialog(playerid,dialogid, extra = -1 ) {
	if( dialogid == DIALOG_PM_MENU ) {
	    g_iDialogEdition{ playerid } = 0;
	    gPM_ClearMessageReceivers( playerid );
		if( gPM_GetNewMessages( g_iUserID[ playerid ] ) ) {
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_LIST , ""#COL_ORANGE"gPM  Menu" , ""COL_WHITE"Posteingang "#COL_GREEN""#MARK_NEW_MESSAGES""#COL_WHITE"\nPostausgang\nNachricht Versenden\nUser Übersicht" , "Weiter" , "Schließen" );
		}
		else {
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_LIST , ""#COL_ORANGE"gPM  Menu" , ""COL_WHITE"Posteingang\nPostausgang\nNachricht Versenden\nUser Übersicht" , "Weiter" , "Schließen" );
		}
		return 1;
	}
	else if( dialogid == DIALOG_PM_EINGANG ) {
		new
			sNachrichtID[ 8 ],
			iNachrichtID,
			sName[ MAX_PLAYER_NAME ],
			iOffset,
			iIndex = 0,
			sStatus[ 2 ],
			sTitel[ 64 ],
			iStatus,
			sText[ INPUT_SIZE ],
			sString[ ( 45 + 4 + 16 + 40) * MAX_QUERY_RESULTS + 1],
			iRows;
		format( g_sQuery , sizeof( g_sQuery ) , "SELECT `NachrichtID`,`Name`,`Status`,`Text` FROM `NACHRICHT`,`USER` WHERE `EmpfaengerID` = '%d' AND `SenderID` = `UserID` AND NOT( `Status` & %d ) ORDER BY `NachrichtID` DESC;" , g_iUserID[ playerid ] , MessageStatus_DEL_Empfaenger );
		g_dbrQuery = db_query( g_dbPM , g_sQuery );
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
				format( sString , sizeof( sString ) , ""#COL_BLUE"<<"#COL_WHITE" Seite zurück ( %d - %d )\n" , ( iOffset - 20 ) , iOffset );
			    #else
				sString = ""#COL_BLUE"<<"#COL_WHITE" Seite zurück\n";
			    #endif
			}
			for(new i = 0 ; i < iOffset ; i++) {
			    db_next_row( g_dbrQuery );
			}
			for(new i = iOffset ; i < iRows ; i++) {
				db_get_field( g_dbrQuery , 0 , sNachrichtID , sizeof( sNachrichtID ) );
				db_get_field( g_dbrQuery , 1 , sName , sizeof(sName ) );
				db_get_field( g_dbrQuery , 2 , sStatus , sizeof( sStatus ) );
				db_get_field( g_dbrQuery , 3 , sText , sizeof( sText ) );
				iNachrichtID = strval( sNachrichtID );
				iStatus = strval( sStatus );
				if( iStatus & MessageStatus_Read ) {
				    if( strlen( sText ) > 16 ) {
						format( sString , sizeof( sString ) ,"%s%.20s - %.16s...\n" , sString , sName , sText );
				    }
				    else {
						format( sString , sizeof( sString ) ,"%s%.20s - %s\n" , sString , sName , sText );
					}
				}
				else  {
				    if( strlen( sText ) > 16 ) {
						format( sString , sizeof( sString ) , "%s%.20s - %.16s... "#COL_GREEN""#MARK_NEW_MESSAGES""#COL_WHITE"\n" , sString , sName , sText );
				    }
				    else {
						format( sString , sizeof( sString ) , "%s%.20s - %s "#COL_GREEN""#MARK_NEW_MESSAGES""#COL_WHITE"\n" , sString , sName , sText );
				    }
				}
				g_iRowUniqueID[ playerid ][ iIndex++ ] = iNachrichtID;
				db_next_row( g_dbrQuery );
			}
			if( iRows < g_iResults[ playerid ] ) {
			    #if defined SHOW_NEXT_PAGES
			    format( sString , sizeof( sString ) ,"%s"#COL_BLUE">> "#COL_WHITE"Nächste Seite ( %d - %d )\n" , sString , ( iRows + 1 ) , ( ( iRows + MAX_QUERY_RESULTS ) > g_iResults[ playerid ] ) ? g_iResults[ playerid ] : ( iRows + MAX_QUERY_RESULTS ) );
			    #else
			    strcat( sString ,""#COL_BLUE">> "#COL_WHITE"Nächste Seite\n", sizeof( sString ) );
			    #endif
			}
			format( sTitel , sizeof( sTitel ) ,""#COL_ORANGE"gPM  Posteingang ( %d - %d ) / %d " , iOffset + 1, iRows , g_iResults[ playerid ] );
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_LIST , sTitel , sString , "Lesen" , "Zurück" );
		}
		else {
			ShowPlayerDialog( playerid , DIALOG_PM_EINGANG_EMPTY , DIALOG_STYLE_MSGBOX , ""#COL_ORANGE"gPM  Posteingang" , ""#COL_WHITE"Du hast keine Nachrichten im Eingang!" , "Zurück" , "" );
		}
		db_free_result( g_dbrQuery );
		return 1;
	}
	else if( dialogid == DIALOG_PM_AUSGANG ) {
		new
			sNachrichtID[ 8 ],
			iNachrichtID,
			iIndex = 0,
			sName[MAX_PLAYER_NAME],
			sStatus[ 2 ],
			iStatus,
			iOffset,
			sTitel[ 64 ],
			sText[ INPUT_SIZE ],
			sString[ ( 45 + 10 + 16 + 4 + 40) * MAX_QUERY_RESULTS + 1],
			iRows;
		format(g_sQuery,sizeof(g_sQuery),"SELECT `NachrichtID`,`Name`,`Status`,`Text` FROM `NACHRICHT`,`USER` WHERE `SenderID` = '%d' AND `EmpfaengerID` = `UserID` AND NOT( `Status` & %d ) ORDER BY `NachrichtID` DESC" , g_iUserID[ playerid ] , MessageStatus_DEL_Sender );
		g_dbrQuery = db_query( g_dbPM , g_sQuery );
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
				format( sString , sizeof( sString ) , ""#COL_BLUE"<<"#COL_WHITE" Seite zurück ( %d - %d )\n" , ( iOffset - MAX_QUERY_RESULTS ) , iOffset );
			    #else
				sString = ""#COL_BLUE"<<"#COL_WHITE" Seite zurück\n";
			    #endif
			}
			for(new i = 0 ; i < iOffset ; i++) {
			    db_next_row( g_dbrQuery );
			}
			for(new i = iOffset ; i < iRows ; i++) {
				db_get_field( g_dbrQuery , 0 , sNachrichtID , sizeof( sNachrichtID ) );
				db_get_field( g_dbrQuery , 1 , sName , sizeof( sName ) );
				db_get_field( g_dbrQuery , 2 , sStatus , sizeof( sStatus ) );
				db_get_field( g_dbrQuery , 3 , sText , sizeof( sText ) );
				iNachrichtID = strval( sNachrichtID );
				iStatus = strval( sStatus );
				if( iStatus & MessageStatus_Read ) {
				    if( strlen( sText ) > 16 ) {
						format( sString , sizeof( sString ) ,"%s%.20s - %.16s...\n" , sString , sName , sText );
				    }
				    else {
						format( sString , sizeof( sString ) ,"%s%.20s - %s\n" , sString , sName , sText );
					}
				}
				else {
				    if( strlen( sText ) > 16 ) {
						format( sString , sizeof( sString ) , "%s%.20s - %.16s... "#COL_RED""#MARK_UNREAD_MESSAGES""#COL_WHITE"\n" , sString , sName , sText );
				    }
				    else {
						format( sString , sizeof( sString ) , "%s%.20s - %s "#COL_RED""#MARK_UNREAD_MESSAGES""#COL_WHITE"\n" , sString , sName , sText );
					}
				}
				g_iRowUniqueID[ playerid ][ iIndex++ ] = iNachrichtID;
				db_next_row( g_dbrQuery );
			}
			if( iRows < g_iResults[ playerid ] ) {
			    #if defined SHOW_NEXT_PAGES
			    format( sString , sizeof( sString ) ,"%s"#COL_BLUE">> "#COL_WHITE"Nächste Seite ( %d - %d )\n" , sString , ( iRows + 1 ) , ( ( iRows + MAX_QUERY_RESULTS ) > g_iResults[ playerid ] ) ? g_iResults[ playerid ] : ( iRows + MAX_QUERY_RESULTS ));
			    #else
			    strcat( sString ,""#COL_BLUE">> "#COL_WHITE"Nächste Seite\n", sizeof( sString ) );
			    #endif
			}
			format( sTitel , sizeof( sTitel ) ,""#COL_ORANGE"gPM  Postausgang ( %d - %d ) / %d " , iOffset + 1, iRows , g_iResults[ playerid ] );
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_LIST , sTitel , sString , "Lesen" , "Zurück" );
		}
		else {
			ShowPlayerDialog( playerid , DIALOG_PM_AUSGANG_EMPTY , DIALOG_STYLE_MSGBOX , ""#COL_ORANGE"gPM  Postausgang" , ""#COL_WHITE"Du hast keine Nachrichten im Ausgang!" , "Zurück" , "" );
		}
		db_free_result( g_dbrQuery );
		return 1;
	}
	else if( ( dialogid == DIALOG_PM_EINGANG_MSG ) || ( dialogid == DIALOG_PM_EINGANG_FILTER_MSG ) ) {
		format( g_sQuery , sizeof( g_sQuery ) , "SELECT `Name`,`Status`, strftime('%s',`Tag`) AS Datum,`Uhrzeit`,`Text` FROM `NACHRICHT`,`User` WHERE `NachrichtID` = '%d' AND `UserID` = `SenderID` " , DATE_FORMAT , ( extra & 0xFFFF ) );
		g_dbrQuery = db_query( g_dbPM , g_sQuery );
		if( db_num_rows( g_dbrQuery ) ) {
	        new
				sStatus[ 2 ],
				sTag[ 12 ],
				sTitel[ 32+16+8 ],
				sName[ MAX_PLAYER_NAME ],
				sUhrzeit[ 12 ],
				iStatus,
				sNachricht[ GPM_MAX_STRING ],
				sString[ 256 + ( GPM_MAX_STRING )  ];
			db_get_field( g_dbrQuery , 0 , sName , sizeof( sName ) );
			db_get_field( g_dbrQuery , 1 , sStatus , sizeof( sStatus ) );
			db_get_field( g_dbrQuery , 2 , sTag , sizeof( sTag ) );
			db_get_field( g_dbrQuery , 3 , sUhrzeit , sizeof( sUhrzeit ) );
			db_get_field( g_dbrQuery , 4 , sNachricht , sizeof( sNachricht ) );
			iStatus = strval( sStatus );
			db_free_result( g_dbrQuery );
			if( !( iStatus & MessageStatus_Read ) ) {
			    iStatus |= MessageStatus_Read;
				format(g_sQuery,sizeof(g_sQuery),"UPDATE `Nachricht` SET `Status` = '%d' WHERE NachrichtID = '%d'" , iStatus , ( extra & 0xFFFF ) );
				db_free_result( db_query( g_dbPM , g_sQuery ) );
			}
			format( sString , sizeof( sString ) , ""#COL_GREY"Von: "#COL_WHITE"%s\n"#COL_GREY"Datum: "#COL_WHITE"%s %s\n\n"#COL_GREY"Nachricht:"#COL_WHITE"\n%s\n\n" , sName , sTag , sUhrzeit , gPM_StripMessageLines( sNachricht ) );
			format( sTitel , sizeof( sTitel ) , ""#COL_ORANGE"gPM  Posteingang - Nachricht (%d)" , ( ( g_iPage[ playerid ] * MAX_QUERY_RESULTS ) + (( extra >> 16 ) & 0xFFFF )) + 1);
			if( dialogid == DIALOG_PM_EINGANG_MSG ) {
			    g_iUserInput[ playerid ] = extra ;
				ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_MSGBOX , sTitel , sString , "Zurück" , "Löschen" );
			}
			else {
				ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_MSGBOX , sTitel , sString , "Zurück" , "" );
			}
		}
		return 1;
	}
	else if( ( dialogid == DIALOG_PM_AUSGANG_MSG ) || ( dialogid == DIALOG_PM_AUSGANG_FILTER_MSG ) ) {
		format( g_sQuery , sizeof( g_sQuery ) , "SELECT `Name`,`Status`, strftime('%s',`Tag`) AS Datum,`Uhrzeit`,`Text` FROM `NACHRICHT`,`User` WHERE `NachrichtID` = '%d' AND `UserID` = `EmpfaengerID`" , DATE_FORMAT , ( extra & 0xFFFF ) );
		g_dbrQuery = db_query( g_dbPM , g_sQuery );
		if( db_num_rows( g_dbrQuery ) ) {
			new
				sStatus[ 2 ],
				sTag[ 12 ],
				sName[ MAX_PLAYER_NAME ],
				sUhrzeit[ 12 ],
				iStatus,
				sNachricht[ GPM_MAX_STRING ],
				sTitel[ 64 ],
				sString[ 256 +  MAX_INPUT_PAGES * INPUT_SIZE  ];
			db_get_field( g_dbrQuery , 0 , sName , sizeof( sName ) );
			db_get_field( g_dbrQuery , 1 , sStatus , sizeof( sStatus ) );
			db_get_field( g_dbrQuery , 2 , sTag , sizeof( sTag ) );
			db_get_field( g_dbrQuery , 3 , sUhrzeit , sizeof( sUhrzeit ) );
			db_get_field( g_dbrQuery , 4 , sNachricht , sizeof( sNachricht ) );
			iStatus = strval( sStatus );
			db_free_result( g_dbrQuery );
			format( sString , sizeof( sString ) , ""#COL_GREY"An: "#COL_WHITE"%s\n"#COL_GREY"Datum: "#COL_WHITE"%s %s\n\n"#COL_GREY"Nachricht:"#COL_WHITE"\n%s\n\n" , sName , sTag , sUhrzeit , gPM_StripMessageLines( sNachricht ) );
			if( !( iStatus & MessageStatus_Read ) ) {
				format( sString , sizeof( sString ) , "%s"#COL_GREY"Status: "#COL_RED"Ungelesen" , sString );
			}
			else {
				format( sString , sizeof( sString ) , "%s"#COL_GREY"Status: "#COL_GREEN"Gelesen" , sString );
			}
			format( sTitel , sizeof( sTitel ) , ""#COL_ORANGE"gPM  Postausgang - Nachricht (%d)" , ( ( g_iPage[ playerid ] * MAX_QUERY_RESULTS ) + (( extra >> 16 ) & 0xFFFF )) + 1);
			if( dialogid == DIALOG_PM_AUSGANG_MSG ) {
			    g_iUserInput[ playerid ] = extra;
				ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_MSGBOX , sTitel , sString , "Zurück" , "Löschen" );
			}
			else {
				ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_MSGBOX , sTitel , sString , "Zurück" , "" );
			}
		}
		return 1;
	}
	else if( dialogid == DIALOG_PM_SCHREIBEN_USER ) {
		if( extra == -1 ) {
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_INPUT , ""#COL_ORANGE"gPM  Nachricht Versenden - User",""#COL_WHITE"Gib unten den exakten Usernamen ein,\nan den du eine Textnachricht versenden möchtest!\n\nDu kannst später noch mehr Empfänger hinzufügen" , "Weiter" , "Zurück" );
		}
		else if(extra == 0 ) {
			new
				sString[ 256 ];
			strunpack( g_supUserInput , g_sUserInput[ playerid ] );
			format( sString , sizeof( sString ) , ""#COL_WHITE"Der genannte User '"#COL_GREY"%s"#COL_WHITE"' konnte nicht in unserer\nDatenbank gefunden werden.\n\nGib unten den exakten Usernamen ein,\nan den du eine Textnachricht versenden möchtest!\n\nDu kannst später noch mehr Empfänger hinzufügen" , g_supUserInput );
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_INPUT , ""#COL_ORANGE"gPM  Nachricht Versenden - User" , sString , "Weiter" , "Zurück" );
		}
		else if( extra == 1 ) {
			ShowPlayerDialog( playerid , DIALOG_PM_SCHREIBEN_USER , DIALOG_STYLE_INPUT , ""#COL_ORANGE"gPM  Nachricht Versenden - User" , ""#COL_WHITE"Du kannst dir selber keine Nachrichten schicken!\n\nGib unten den exakten Usernamen ein,\nan den du eine Textnachricht versenden möchtest!\n\nDu kannst später noch mehr Empfänger hinzufügen" , "Weiter" , "Zurück" );
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
		strcat( sHuge , gPM_ListmessageReceivers( playerid , true ) , sizeof( sHuge ));
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
	#if defined EDIT_MESSAGES
	else if( dialogid == DIALOG_PM_SCHREIBEN_BEARBEITEN ) {
	    new
	        usMessage[ INPUT_SIZE ],
	        sString[ MAX_INPUT_PAGES * ( 18 + 3 + 5) + 1];
		for(new i ; i < g_iUserMessageInput{ playerid } ; i++) {
		    strunpack( usMessage , g_sUserMessageInput[ playerid ][ i ] );
		    format(sString,sizeof(sString),"%s%d) %.18s ...\n" , sString , i + 1 , usMessage );
		}
		ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_LIST , ""#COL_ORANGE"gPM   Nachricht bearbeiten" , sString , "Öffnen" , "Zurück" );
	}
	#endif
	else if( dialogid == DIALOG_PM_USER_UEBERSICHT ) {
		if( extra == -1 ) {
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_INPUT , ""#COL_ORANGE"gPM   User Übersicht" , ""#COL_WHITE"Du kannst einen User suchen, indem du unten in das\ndas Feld seinen Namen eingibst" , "Suchen" , "Zurück" );
	    }
	    else if( extra == 0 ) {
	        new
				sString[ 256 ];
			strunpack( g_supUserInput , g_sUserInput[ playerid ] );
			format( sString , sizeof( sString ) , ""#COL_WHITE"Es wurden keine User mit dem Suchkriterium '"#COL_GREY"%s"#COL_WHITE"' gefunden.\n\nDu kannst einen User suchen, indem du unten in \ndas Feld seinen Namen eingibst" , g_supUserInput );
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_INPUT , ""#COL_ORANGE"gPM  User Übersicht" , sString , "Suchen" , "Zurück" );
	    }
	    else if( extra == 1 ) {
	        new
				sString[ 256 ];
			strunpack( g_supUserInput , g_sUserInput[ playerid ] );
			format( sString , sizeof( sString ) , ""#COL_WHITE"Es wurden zu viele User über das Suchkriterium '"COL_GREY"%s"#COL_WHITE"' gefunden.\nDu kannst einen User suchen, indem du unten in \ndas Feld seinen Namen eingibst." , g_supUserInput );
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_INPUT , ""#COL_ORANGE"gPM  User Übersicht" , sString , "Suchen" , "Zurück" );
	    }
	    else if( extra == 2 ) {
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_INPUT , ""#COL_ORANGE"gPM  User Übersicht" , ""#COL_WHITE"Deine Eingabe war zu kurz oder nicht vorhanden!\n\nDu kannst einen User suchen, indem du unten in das\ndas Feld seinen Namen eingibst" , "Suchen" , "Zurück" );
	    }
		return 1;
	}
	else if( dialogid == DIALOG_PM_USER_UEBERSICHT_QUERY ) {
	    new
			sString[ MAX_PLAYER_NAME * MAX_QUERY_RESULTS ],
			sUserID[ 8 ],
			sTitel[ 64 ],
			sName[ MAX_PLAYER_NAME ],
			iRows;
		g_dbrQuery = DBResult:extra;
		iRows = db_num_rows( g_dbrQuery );
		for(new i = 0 ; i < iRows ; i++) {
			db_get_field( g_dbrQuery , 0 , sUserID , sizeof( sUserID ) );
			db_get_field( g_dbrQuery , 1 , sName , sizeof( sName ) );
			g_iRowUniqueID[ playerid ][ i ] = strval( sUserID );
			format( sString  ,sizeof(sString) , "%s%s\n" , sString , sName );
			db_next_row( g_dbrQuery );
		}
		strunpack( g_supUserInput , g_sUserInput[ playerid ] );
		format( sTitel , sizeof( sTitel ) , ""#COL_ORANGE"gPM Nachricht  User Übersicht - Filter '%s' (%d)" , g_supUserInput , iRows );
		if( g_iDialogEdition{ playerid } == DIALOG_EDITION_NORMAL ) {
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_LIST , sTitel , sString , "Verarbeitung" , "Zurück" );
		}
		else if( g_iDialogEdition{ playerid } == DIALOG_EDITION_ADD_EMPFAENGER ) {
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_LIST , sTitel , sString , "Hinzufügen" , "Zurück" );
		}
		db_free_result( g_dbrQuery );
		return 1;
	}
	else if( dialogid == DIALOG_PM_USER_VERARBEITUNG ) {
	    new
			sTitel[ 80 ];
		strunpack( g_supUserInput , g_sUserInput[ playerid ] );
		format( sTitel , sizeof( sTitel ) , ""#COL_ORANGE"gPM Nachricht  User Übersicht - Verarbeitung '%s'" , g_supUserInput );
		ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_LIST , sTitel , "Posteingang\nPostausgang\nNachricht Senden" , "Durchführen" , "Zurück" );
	}
	else if( dialogid == DIALOG_PM_SCHREIBEN_MENU ) {
	    new
	        sListtext[ 128 ];
		/*
	    if( g_iUserMessageInput[ playerid ] == 0 ) {
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_LIST , ""#COL_ORANGE"gPM  Nachricht Versenden - Menu" , "Versenden\n"#COL_RED"Schreiben fortsetzen\n" , "Weiter" , "Zurück" );
	    }
	    */
        if( g_iUsersMessageReceivers{ playerid } < 1 ) {
	        sListtext = "Versenden ( "#COL_RED"0 Empfänger"#COL_WHITE" )\n";
		}
		else {
	        sListtext = "Versenden\n";
		}
	    if( g_iUserMessageInput{ playerid } >= MAX_INPUT_PAGES ) {
	        format( sListtext , sizeof( sListtext ) , "%s"#COL_RED"Schreiben fortsetzen\n",sListtext);
		}
	    else {
	        format( sListtext , sizeof( sListtext ) , "%s"#COL_GREEN"Schreiben fortsetzen\n",sListtext);
	    }
        format( sListtext , sizeof( sListtext ) , "%s"#COL_WHITE"Empfänger bearbeiten\n",sListtext);
	    #if defined EDIT_MESSAGES
	    else if( g_iUserMessageInput{ playerid } >= MAX_INPUT_PAGES ) {
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_LIST , ""#COL_ORANGE"gPM  Nachricht Versenden - Menu" , "Versenden\n"#COL_RED"Schreiben fortsetzen\n"#COL_WHITE"Texte Bearbeiten" , "Weiter" , "Zurück" );
		}
	    else {
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_LIST , ""#COL_ORANGE"gPM  Nachricht Versenden - Menu" , "Versenden\n"#COL_GREEN"Schreiben fortsetzen\n"#COL_WHITE"Texte Bearbeiten" , "Weiter" , "Zurück" );
	    }
	    #endif
		ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_LIST , ""#COL_ORANGE"gPM  Nachricht Versenden - Menu" , sListtext , "Weiter" , "Zurück" );
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
			sNachrichtID[ 8 ],
			iNachrichtID,
			sName[ MAX_PLAYER_NAME ],
			sStatus[ 2 ],
			sTitel[ 64 ],
			iStatus,
			sText[ INPUT_SIZE ],
			sString[ ( 45 + 4 + 16 + 40) * MAX_QUERY_RESULTS + 1];
		format( g_sQuery , sizeof( g_sQuery ) , "SELECT `NachrichtID`,`Name`,`Status`,`Text` FROM `NACHRICHT`,`USER` WHERE `EmpfaengerID` = '%d' AND `SenderID` = '%d' AND `SenderID` = `UserID` AND NOT( `Status` & %d ) ORDER BY `NachrichtID` DESC LIMIT %d;" , g_iUserID[ playerid ] , g_iUserInput[ playerid ] , MessageStatus_DEL_Empfaenger , MAX_QUERY_RESULTS);
		print( g_sQuery );
		g_dbrQuery = db_query( g_dbPM , g_sQuery );
		g_iResults[ playerid ] = db_num_rows( g_dbrQuery );
		if( g_iResults[ playerid ] ) {
			sString[0] = '\0';
			for(new i = 0 ; i < g_iResults[ playerid ] ; i++) {
				db_get_field( g_dbrQuery , 0 , sNachrichtID , sizeof( sNachrichtID ) );
				db_get_field( g_dbrQuery , 1 , sName , sizeof(sName ) );
				db_get_field( g_dbrQuery , 2 , sStatus , sizeof( sStatus ) );
				db_get_field( g_dbrQuery , 3 , sText , sizeof( sText ) );
				iNachrichtID = strval( sNachrichtID );
				iStatus = strval( sStatus );
				if( iStatus & MessageStatus_Read ) {
				    if( strlen( sText ) > 16 ) {
						format( sString , sizeof( sString ) ,"%s%.20s - %.16s...\n" , sString , sName , sText );
				    }
				    else {
						format( sString , sizeof( sString ) ,"%s%.20s - %s\n" , sString , sName , sText );
				    }
				}
				else  {
				    if( strlen( sText ) > 16 ) {
						format( sString , sizeof( sString ) , "%s%.20s - %.16s... "#COL_GREEN""#MARK_NEW_MESSAGES""#COL_WHITE"\n" , sString , sName , sText );
				    }
				    else {
						format( sString , sizeof( sString ) , "%s%.20s - %s "#COL_GREEN""#MARK_NEW_MESSAGES""#COL_WHITE"\n" , sString , sName , sText );
				    }
				}
				g_iRowUniqueID[ playerid ][ i ] = iNachrichtID;
				db_next_row( g_dbrQuery );
			}
			g_supUserInput[ 0 ] = '\0';
			strunpack( g_supUserInput , g_sUserInput[ playerid ] );
			format( sTitel , sizeof( sTitel ) ,""#COL_ORANGE"gPM  Posteingang ( %s ) " , g_supUserInput );
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_LIST , sTitel , sString , "Lesen" , "Zurück" );
		}
		else {
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_MSGBOX , ""#COL_ORANGE"gPM  Posteingang" , ""#COL_WHITE"Du hast keine Nachrichten im Eingang!" , "Zurück" , "" );
		}
		db_free_result( g_dbrQuery );
		return 1;
	}
	else if( dialogid == DIALOG_PM_AUSGANG_FILTER ) {
		new
			sNachrichtID[ 8 ],
			iNachrichtID,
			sName[MAX_PLAYER_NAME],
			sStatus[ 2 ],
			iStatus,
			sTitel[ 64 ],
			sText[ INPUT_SIZE ],
			sString[ ( 45 + 10 + 16 + 4 + 40) * MAX_QUERY_RESULTS + 1];
		format(g_sQuery,sizeof(g_sQuery),"SELECT `NachrichtID`,`Name`,`Status`,`Text` FROM `NACHRICHT`,`USER` WHERE `SenderID` = '%d' AND `EmpfaengerID` = '%d' AND `EmpfaengerID` = `UserID` AND NOT( `Status` & %d ) ORDER BY `NachrichtID` DESC" , g_iUserID[ playerid ] , g_iUserInput[ playerid ] , MessageStatus_DEL_Sender );
		g_dbrQuery = db_query( g_dbPM , g_sQuery );
		g_iResults[ playerid ] = db_num_rows( g_dbrQuery );
		if( g_iResults[ playerid ] ) {
			sString[0] = '\0';
			for(new i = 0 ; i < g_iResults[ playerid ] ; i++) {
				db_get_field( g_dbrQuery , 0 , sNachrichtID , sizeof( sNachrichtID ) );
				db_get_field( g_dbrQuery , 1 , sName , sizeof( sName ) );
				db_get_field( g_dbrQuery , 2 , sStatus , sizeof( sStatus ) );
				db_get_field( g_dbrQuery , 3 , sText , sizeof( sText ) );
				iNachrichtID = strval( sNachrichtID );
				iStatus = strval( sStatus );
				if( iStatus & MessageStatus_Read ) {
				    if( strlen( sText ) > 16 ) {
						format( sString , sizeof( sString ) ,"%s%.20s - %.16s...\n" , sString , sName , sText );
				    }
				    else {
						format( sString , sizeof( sString ) ,"%s%.20s - %s\n" , sString , sName , sText );
				    }
				}
				else {
				    if( strlen( sText ) > 16 ) {
						format( sString , sizeof( sString ) , "%s%.20s - %.16s... "#COL_RED""#MARK_UNREAD_MESSAGES""#COL_WHITE"\n" , sString , sName , sText );
				    }
				    else {
						format( sString , sizeof( sString ) , "%s%.20s - %s "#COL_RED""#MARK_UNREAD_MESSAGES""#COL_WHITE"\n" , sString , sName , sText );
				    }
				}
				g_iRowUniqueID[ playerid ][ i ] = iNachrichtID;
				db_next_row( g_dbrQuery );
			}
			g_supUserInput[ 0 ] = '\0';
			strunpack( g_supUserInput , g_sUserInput[ playerid ] );
			format( sTitel , sizeof( sTitel ) , ""#COL_ORANGE"gPM  Postausgang ( %s )" , g_supUserInput);
			ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_LIST , sTitel , sString , "Lesen" , "Zurück" );
		}
		else {
			ShowPlayerDialog( playerid , DIALOG_PM_AUSGANG_EMPTY , DIALOG_STYLE_MSGBOX , ""#COL_ORANGE"gPM  Postausgang" , ""#COL_WHITE"Du hast keine Nachrichten im Ausgang!" , "Zurück" , "" );
		}
		db_free_result( g_dbrQuery );
		return 1;
	}
	else if( dialogid == DIALOG_PM_SCHREIBEN_EMPF_EDIT ) {
	    new
	        sTitel[ 64 ],
	        sListtext[ ( MAX_MESSAGE_RECEIVERS * ( MAX_PLAYER_NAME + 2 ) ) + 32 ];
        sListtext = ""#COL_BLUE"<<"#COL_WHITE" Zurück\n";
		strcat( sListtext , gPM_ListmessageReceivers( playerid ) , sizeof( sListtext ) );
		if( g_iUsersMessageReceivers{ playerid } >= MAX_MESSAGE_RECEIVERS ) {
		    format( sListtext , sizeof(sListtext) , "%s"#COL_RED"Empfänger hinzufügen\n" , sListtext );
		}
		else {
		    format( sListtext , sizeof(sListtext) , "%s"#COL_GREEN"Empfänger hinzufügen\n" , sListtext );
		}
		g_iDialogEdition{ playerid } = DIALOG_EDITION_ADD_EMPFAENGER;
		format( sTitel , sizeof( sTitel ) , ""#COL_ORANGE"gPM  Empfänger bearbeiten ( %d / "#MAX_MESSAGE_RECEIVERS" )" , g_iUsersMessageReceivers{ playerid } );
		ShowPlayerDialog( playerid , dialogid , DIALOG_STYLE_LIST , sTitel , sListtext , "Weiter" , "Löschen" );
	}
	return 1;
}
stock gPM_OnDialogResponse( playerid, dialogid , response , listitem , inputtext[] ) {
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
			if( iUserID == INVALID_USERID ) {
				return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_USER , 0 );
			}
			if( iUserID == g_iUserID[ playerid ] ) {
				return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_USER , 1 );
			}
			g_iUserInput[ playerid ] = iUserID;
			gPM_AddMessageReceiver( playerid , iUserID );
			g_iUserMessageInput{ playerid } = 0;
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
		    else {
				return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_USER );
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
			    gPM_AddMessageReceiver( playerid , g_iUserInput[ playerid ] );
				return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_EMPF_EDIT );
			}
	    }
	    else {
			return gPM_ShowDialog( playerid , DIALOG_PM_USER_UEBERSICHT );
	    }
	}
	else if ( dialogid == DIALOG_PM_EINGANG_EMPTY ) {
		return gPM_ShowDialog( playerid , DIALOG_PM_MENU );
	}
	else if ( dialogid == DIALOG_PM_AUSGANG_EMPTY ) {
		return gPM_ShowDialog( playerid , DIALOG_PM_MENU );
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
			        gPM_AddMessageReceiver( playerid , g_iUserInput[ playerid ] );
			        return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_TEXT );
			    }
			}
	    }
	    else {
	    
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
			    #if defined EDIT_MESSAGES
			    case 3: {
			        return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_BEARBEITEN );
			    }
			    #endif
			}
	    }
	    else {
	        return gPM_ShowDialog( playerid , DIALOG_PM_MENU );
	    }
	}
	else if( dialogid == DIALOG_PM_EINGANG_FILTER ) {
	    if(response) {
	        return gPM_ShowDialog( playerid , DIALOG_PM_EINGANG_FILTER_MSG , g_iRowUniqueID[ playerid ][ listitem ] );
	    }
	    else {
	        return gPM_ShowDialog( playerid , DIALOG_PM_USER_VERARBEITUNG );
	    }
	}
	else if( dialogid == DIALOG_PM_AUSGANG_FILTER ) {
	    if(response) {
	        return gPM_ShowDialog( playerid , DIALOG_PM_AUSGANG_FILTER_MSG , g_iRowUniqueID[ playerid ][ listitem ] );
	    }
	    else {
	        return gPM_ShowDialog( playerid , DIALOG_PM_USER_VERARBEITUNG );
	    }
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
				gPM_RemoveMessageReceiver( playerid , gPM_GetUserID( inputtext ) );
	            return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_EMPF_EDIT );
	        }
	        else {
	            return gPM_ShowDialog( playerid , DIALOG_PM_SCHREIBEN_MENU );
	        }
	    }
	}
	return 0;
}

COMMAND:gpm(playerid,params[]) {
	if( g_bHas_gPMUC ) {
		if( !CallRemoteFunction( GPM_USERCALL_FUNCTION , "d" , playerid ) ) {
		    new
		        sString[ 128 ];
			GetPlayerName(playerid, sString , sizeof( sString ) );
			format( sString , sizeof( sString ) , "* gPM: Du wurdest mit dem Usernamen '%s' nicht zertifiziert!" , sString );
		    SendClientMessage( playerid , COLOR_RED , sString);
		    return 1;
		}
	}
	return gPM_ShowDialog( playerid , DIALOG_PM_MENU );
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
			if( gPM_GetUserID( _sTmp ) == INVALID_USERID ) {
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

stock gPM_FilterUsernames( my_userid , const username_filter[] , & DBResult:dbr ) {
	format( g_sQuery , sizeof( g_sQuery ) , "SELECT * FROM `USER` WHERE `Name` LIKE '%%%s%%' AND NOT(`UserID` = '%d') ORDER BY `Name` ASC" , username_filter , my_userid );
	dbr = db_query( g_dbPM , g_sQuery );
	return 1;
}

stock gPM_GetUsers() {
	new
		sUsers[8],
		iUsers;
	g_dbrQuery = db_query( g_dbPM , "SELECT COUNT(*) FROM `User`" );
	db_get_field( g_dbrQuery , 0 , sUsers , sizeof( sUsers ) );
	iUsers = strval( sUsers );
    db_free_result( g_dbrQuery );
	return iUsers;
}

stock gPM_GetNachrichten() {
	new
		sNachrichten[8],
		iNachrichten;
	g_dbrQuery = db_query( g_dbPM , "SELECT COUNT(*) FROM `Nachricht`" );
	db_get_field( g_dbrQuery , 0 , sNachrichten , sizeof( sNachrichten ) );
	iNachrichten = strval( sNachrichten );
	db_free_result( g_dbrQuery );
	return iNachrichten;
}

stock gPM_GetUsername( userid ) {
	new
		sUsername[ MAX_PLAYER_NAME ] = "INVALID_USERNAME";
	format( g_sQuery , sizeof( g_sQuery ) , "SELECT `Name` FROM `User` WHERE `UserID` = '%d'" , userid );
	g_dbrQuery = db_query( g_dbPM , g_sQuery );
	if( db_num_rows( g_dbrQuery ) ) {
		db_get_field( g_dbrQuery , 0 , sUsername , sizeof( sUsername ) );
	}
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
stock gPM_MergeMessages( playerid ) {
    g_supMessageSingleInput[ 0 ] = '\0';
    g_supMessageInput[ 0 ] = '\0';
	for(new i = 0 ; i < g_iUserMessageInput{ playerid } ; i++) {
	    strunpack( g_supMessageSingleInput , g_sUserMessageInput[ playerid ][ i ] );
		strcat( g_supMessageInput , g_supMessageSingleInput );
	}
	return g_supMessageInput;
}

stock gPM_ClearMessageReceivers( playerid ) {
	if( g_iUsersMessageReceivers{ playerid } ) {
		for(new i = 0 ; i < MAX_MESSAGE_RECEIVERS ; i++ ) {
		    g_aiUserMessageReceivers[ playerid ][ i ] = INVALID_USERID;
		}
		g_iUsersMessageReceivers{ playerid } = 0;
	}
	return 1;
}

stock gPM_AddMessageReceiver( playerid , receiverid ) {
	if( g_iUsersMessageReceivers{ playerid } >= MAX_MESSAGE_RECEIVERS ) {
	    return 0;
	}
	for( new i = 0 ; i < g_iUsersMessageReceivers{ playerid } ; i++) {
	    if( g_aiUserMessageReceivers[ playerid ][ i ] == receiverid ) {
	        return 2;
	    }
	}
	g_aiUserMessageReceivers[ playerid ][ g_iUsersMessageReceivers{ playerid } ] = receiverid;
    g_iUsersMessageReceivers{ playerid }++;
    return 1;
}

stock gPM_RemoveMessageReceiver( playerid , receiverid ) {
	for( new i = 0 ; i < g_iUsersMessageReceivers{ playerid } ; i++) {
	    if( g_aiUserMessageReceivers[ playerid ][ i ] == receiverid ) {
			for(new j = i ; j < g_iUsersMessageReceivers{ playerid } - 1; j++) {
				g_aiUserMessageReceivers[ playerid ][ j ] = g_aiUserMessageReceivers[ playerid ][ j + 1 ];
			}
			break;
	    }
	}
	g_iUsersMessageReceivers{ playerid }--;
	return 1;
}

stock gPM_ListmessageReceivers( playerid , bool:bForList = false) {
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
	format( g_sQuery , sizeof( g_sQuery ) , "SELECT `Name` FROM `USER` WHERE `UserID` IN(%s)" , sUserIDs );
	g_dbrQuery = db_query( g_dbPM , g_sQuery );
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

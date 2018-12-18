//
// Unit: TSUK_ConstsU
// Author: M.A.Sargent  Date: 15/03/18  Version: V1.0
//
// Notes:
//
unit TSUK_ConstsU;

interface

Uses Messages, SysUtils, MAS_JSonU, VerboseLevelTypeU;

Type
  tServerCommands = (scUnknown, scLogin, scHeartBeat, scConnectionInfo, scExpiryDate, scExpiryDateEnabled, scNumberExployees, scTotalUsers,
                      scCurrentlyConnectUsers, scGetSerialNumber, scGetLicenseNumber, scSetLicenseNumber, scGeneric,
                       scDownLoadLicense, scPing);

  tActivationServerCommands = (ascUnknown, ascReloadSecurityInfo, ascCheckLicense, ascDownloadLicense, ascTableAction, ascTableQuery, ascClientActivate);
  //
  tQueryName   = (qmCompany, qmCompanyLicenses, qmSoftwareProducts, qmActivations, qmBlackList, qmConnectionsPerMonth, qmRegion, qmUserNames,
                   qmSoftwareCategory);
  tTableAction = (taInsert, taUpdate, taDelete, taQuery1, taQuery2, taQuery3, taProc);
  tTableName   = (tnCustomerInfo, tnSoftwareProduct, tnCustomerLicense, tnLicenseActivations, tnBlackList, tnUserAccounts, tnLookupCodes);
  //
  tCommonProcedures = (cpDeAllocate, cpCheckSalesNumber, cpInsBlackList, cpDelBlackList,
                       {} cpActive, cpLock, cpDelete, cpUpdateSageAccountNumber);

  tAccountType = (atUnKnown, atActivation, atClient);

  tFeedBackMessages = (fmStats, fmCount, fmCommand, fmSessions, fmServerStats, fmTCPThreadException);
  //
  tApplicationMessages = (amOpenConnection, amCloseConnection, amHeartBeat);
  //
  tBlackListType = (bltFingerPrint, bltIP);
  tMutexEntry    = (meUnAssigned, meNoThreadEntry, meExistsDiffName, meExists);

  //
  tLicenseOptions = (loUnKnown, loLicenseServer, loDeskTop, loSpare1, loSpare2);
  tTimeSystemsRegions = (tsrAll, tsrUK, tsrUSA, tsrSpanish);
  //
  tActivationFileStatus = (afsUnknown, afsOK, afsNotActive, afsValidationRequired, afsLicenseExpired, afsIniLoadError, afsIniNotFound);
  //
  tCheckLicense     = (clOK, clNotFound, clNotActive, clExpired, clUpdateExists, clBlackListed, clCustomerNotActive, clActivateDisabled);
  tActivationResult = (arOK, arNotFound, arNotActive, arNoLicenseFree, arBlackListed, arFailed, arParamsMixNotFound, arAlreadyActivated, arCustomerNotActive, arActivateDisabled);
  tDbResult         = (drOK, drNoRowUpdated, drTooManyRows);
  tActivationValue = (avActive, avExpiryEnabled, avExpiryDate, avEmployees, avTotalUsers, avRegion,
                       avProductName, avProductVersion, avLicenseOptions, avAllowActivation, avFingerPrint, avSageNumber, avSalesNumber);

  tTypeMsg = (tmInformation, tmWarning, tmError, tmException, tmCritical, tmHeartBeat, tmAdmin, tmVerbose);
  
  eTCPException         = Class (Exception);
   eClientTCPConnection = Class (eTCPException);
   eClientLoginFailure  = Class (eClientTCPConnection);
   eClientNotLoggedOn   = Class (eClientTCPConnection);
  eServerTCPConnection  = Class (eTCPException);

  // Polling Service Exceptions
  eServiceException     = Class (Exception);
   // Service Terminated
   eServiceTerminate    = Class (eServiceException);
   // eServiceAbort
   eServiceAbort        = Class (eServiceException);
   // Currently the Only Exception that will cause the Service to Abort as it can not
   // write log file info to the disk
   eLogWriterFailAbort  = class (eServiceAbort);

  //
  tPollingFileType   = (pftEveryTime, pftJustOnce);
  tPollingFileStatus = (pfsNew, pfsProcessed, pfsExcluded, pfsSuspect);

  // Verbose Level
  //tTSVerboseLevel = (vlNormal, vlFull, vlError, vlException);

  tFourIntegerRec = Record
    Int1: Integer;
    Int2: Integer;
    Int3: Integer;
    Int4: Integer;
    {$IFDEF VER150}
    {$ELSE}
    Procedure Clear;
    {$ENDIF}
  End;

  tOnMessage  = Procedure (Const aVerboseLevel: tTSVerboseLevel; Const aMsg: String) of object;

  tVerboseLevelRec = Record
    fVerboseLevel: tTSVerboseLevel;
    fMsg: String;
    {$IFDEF VER150}
    {$ELSE}
    Procedure Clear;
    Procedure SetValue (Const aMsg: String); overload;
    Procedure SetValue (Const aFormat: String; Const Args: Array of Const); overload;
    Procedure SetValue (Const aValue: tTSVerboseLevel; Const aMsg: String); overload;
    Procedure SetValue (Const aValue: tTSVerboseLevel; Const aFormat: String; Const Args: Array of Const); overload;
    Function  ToJSon: String;
    Procedure FromJSon (Const aJSonString: tJSonString2);
    {$ENDIF}
  End;

  tUserInfoRec = Record
    Username: String;
    Password: String;
    Token:    String;
    {$IFDEF VER150}
    {$ELSE}
    Procedure Clear;
    Procedure SetValue (Const aUsername, aPassword: String); overload;
    Procedure SetValue (Const aUsername, aPassword, aToken: String); overload;
    Function  ToJSon: String;
    Procedure FromJSon (Const aJSonString: tJSonString2);
    {$ENDIF}
  End;

  tUserLogon = Record
    OK: Boolean;
    UserInfo: tUserInfoRec;
    {$IFDEF VER150}
    {$ELSE}
    Procedure Clear;
    //Procedure SetValue (Const aUsername, aPassword: String); overload;
    Procedure SetValue (Const aUsername, aPassword, aToken: String); overload;
    {$ENDIF}
  End;

  tTCPLogon = Record
    Url, UserName, Password: String;
    Port: Integer;
    {$IFDEF VER150}
    {$ELSE}
    Procedure Clear;
    Procedure SetValue (Const aUrl, aUsername, aPassword: String; Const aPort: Integer); overload;
    {$ENDIF}
  End;

Const
  cREPLY_CODE_100                = 100;
  cREPLY_CODE_200                = 200;
  cREPLY_CODE_300                = 300;
  cREPLY_CODE_400                = 400;
  cREPLY_CODE_500                = 500;
  cREPLY_CODE_600                = 600;                        {All TS Commands}
   cREPLY_CODE_HEARTBEAT_OK      = (cREPLY_CODE_600 + 1);      {Reply to HeartBeat}
   cREPLY_CODE_MODULENAME_OK     = (cREPLY_CODE_600 + 2);      {Reply to ModuleName}
   cREPLY_CODE_OK                = (cREPLY_CODE_600 + 3);      {Reply to Commands OK}
   cREPLY_CODE_NOT_FOUND         = (cREPLY_CODE_600 + 4);      {Reply to Commands NOT Found}
   cREPLY_CODE_NOT_PARAM_ERROR   = (cREPLY_CODE_600 + 5);      {Reply to Commands Invalid Parameters}
   cREPLY_CODE_GENERIC_NOT_FOUND = (cREPLY_CODE_600 + 6);      {Reply to Generic Commands NOT Found}
   cREPLY_CODE_LOGON_OK          = (cREPLY_CODE_600 + 7);      {Reply to Logon}
   cREPLY_CODE_LOGON_FAILED      = (cREPLY_CODE_600 + 8);      {Reply to Logon Failed}
   cREPLY_CODE_PING_OK           = (cREPLY_CODE_600 + 9);      {Reply to Ping}
   cREPLY_CODE_COMMAND_ERROR     = (cREPLY_CODE_600 + 98);     {Reply to Error in processing Command}
   cREPLY_CODE_COMMAND_UNKNOWN   = (cREPLY_CODE_600 + 99);     {Reply to Unknown Command}
  cREPLY_CODE_999                = 999;

  // Common Text Strings
  cOK                          = 'OK';

  // Service Server Constats
  cSERVICE                                  = 'Service';
    cSERVICE_PORT                           = 'Port';
    //
    cSERVICE_PORT_LICENSESERVICE_DEFAULT    = 1691;  // 8090 & 8091
    cSERVICE_PORT_ACTIVATIONSERVICE_DEFAULT = 7131;  // Value assigned by Lee
    //
    cSERVICE_DNSNAME                        = 'activation.timesystemsuk.com';

    //
  cSERVICE_OPTION                           = 'ServiceOptions';
    cSERVICE_TCPRESTARTCOUNT                = 'TCPRestartCount';
  //
  cSERVICE_CONFIG                           = 'ServiceConfig';
    cSERVICE_SUSPECTMINUTES                 = 'SuspectMinutes';
    cSERVICE_SUSPECTMINUTES_DEFAULT         = 5;  // Minutes
    cSERVICE_SUSPECTMINUTES_ENABLED         = 'SuspectMinutesEnabled';
    cSERVICE_LOGHISTORY                     = 'LogHistory';
    cSERVICE_LOGHISTORY_MAXSIZE             = 'LogHistoryMaxSize';
    cSERVICE_LOGHISTORY_ADDHEARTBEAT        = 'LogHistoryAddHeartBeats';
    cSERVICE_LOGHISTORY_DUMPHISTORY         = 'LogHistoryDumpHistory';
    cSERVICE_VERBOSE_LEVEL                  = 'VerboseLevel';
    cSERVICE_VERBOSE_LEVEL_DEFAULT          = 0;
    cSERVICE_VERBOSE_LEVEL_CONNECT          = 'VerboseLevelConnect';
    cSERVICE_VERBOSE_LEVEL_CONNECT_DEFAULT  = 0;
    //
    cSERVICE_MSGQUEUE_SIZE                  = 'MessageQueueSize';
    cSERVICE_MSGQUEUE_PUSHTIMEOUT           = 'MessageQueuePushTimeOut';
    cSERVICE_MSGQUEUE_PULLTIMEOUT           = 'MessageQueuePullTimeOut';
    //
    cSERVICE_DF_WRITE_MSGQUEUE_SIZE         = 'MessageQueueSize';
    cSERVICE_DF_WRITE_MSGQUEUE_PUSHTIMEOUT  = 'MessageQueuePushTimeOut';
    cSERVICE_DF_WRITE_MSGQUEUE_PULLTIMEOUT  = 'MessageQueuePullTimeOut';
  //
  cSERVICE_LOGFILE                          = 'ServerLogFile';
    cSERVICE_LOGFILE_DIR                    = 'LogFileDir';
    cSERVICE_LOGFILE_FILENAME               = 'LogFileName';

  // Service Commands as Strings

  cSERVER_COMMANDS : array[0..14] of string = ('UNKNOWN', 'LOGIN', 'HEARTBEAT', 'MODULENAME', 'EXPDATE', 'EXPDATEENABLED', 'NOEMPLOYEES', 'TOTALUSERS',
                                                'CONNECTEDUSERS', 'GETSERIALNUMBER', 'GETLICENSENUMBER', 'SETLICENSENUMBER', 'GENERIC', 'DOWNLOADLICENSE', 'PING');

  cACTIVATION_SERVER_COMMANDS : array[0..6] of string = ('UNKNOWN','RELOADSECURITYINFO', 'CHECKLICENSE', 'DOWNLOADLICENSE', 'TABLEACTION', 'TABLEQUERY', 'CLIENTACTIVATE');

  // FTP Client Constants
  cCLIENT                                   = 'Client';
    cCLIENT_PORT                            = 'Port';
    cCLIENT_PORT_DEFAULT                    = 1691;  // 8090 & 8091
    cCLIENT_HOST                            = 'Host';
    cCLIENT_HOST_DEFAULT                    = '127.0.0.1';
    cCLIENT_CONNECT_TIMEOUT                 = 'ConnectTimeOut';
    cCLIENT_CONNECT_TIMEOUT_DEFAULT         = 5000;
    //
    cCLIENT_USERNAME                        = 'UserName';
    cCLIENT_PASSWORD                        = 'PassWord';

  //
  cCLIENT_CONFIG                            = 'ClientConfig';
    cCLIENT_HEARTBEAT_INTERVAL              = 'HeartBeatInterval';
    cCLIENT_HEARTBEAT_INTERVAL_DEFAULT      = 1;  // Minutes
    cCLIENT_HEARTBEAT_ENABLED               = 'HeartBeatEnabled';
    cCLIENT_CONNECTION_RETRY_COUNT          = 'ConnectionRetryCount';
    cCLIENT_CONNECTION_RETRY_COUNT_DEFAULT  = 2;
    cCLIENT_VERBOSE_LEVEL                   = 'VerboseLevel';
    cCLIENT_VERBOSE_LEVEL_DEFAULT           = 0;
  cCLIENT_LOGFILE                            = 'ClientLogFile';
    cCLIENT_LOGFILE_DIR                      = 'LogFileDir';
    cCLIENT_LOGFILE_FILENAME                 = 'LogFileName';
    cCLIENT_LOGFILE_FILENAMETYPE             = 'LogFileNameType';
    //
    cCLIENT_LOGFILE_DEBUG                        = 'Debug';
    cCLIENT_LOGFILE_DEBUG_DIR                    = 'DebugDirectory';
    cCLIENT_LOGFILE_QUEUESIZE                    = 'QueueSize';
    cCLIENT_LOGFILE_QUEUESIZE_DEFAULT_CLIENT     = 500;
    cCLIENT_LOGFILE_QUEUESIZE_DEFAULT_SERVER     = 1500;
    cCLIENT_LOGFILE_PUSHTIMEOUT                  = 'PushTimeOut';
    cCLIENT_LOGFILE_PUSHTIMEOUT_DEFAULT          = 10000;
    cCLIENT_LOGFILE_POPTIMEOUT                   = 'PullTimeOut';
    cCLIENT_LOGFILE_POPTIMEOUT_DEFAULT           = 1000;

  // License Server Thread to Activation Server
  cLS2AS                                    = 'LicenseToActivation';
    cLS2AS_USERNAME                         = 'UserName';
    cLS2AS_PASSWORD                         = 'Password';
    cLS2AS_HOST                             = 'Host';
    cLS2AS_PORT                             = 'Port';
    cLS2AS_CONNECTIONTIMEOUT                = 'ConnectionTimeOut';

  // Directories
  cOUTPUT_DIR                               = 'Output';
  cOUTPUT_DIR_LOGFILES                      = 'Output\LogFiles';
  cOUTPUT_DIR_DUMPFILES                     = 'Output\DumpFiles';

  // FileNames
  cFILENAME_LOGFILE_TCP_CLIENT              = 'LogFile_TCPClient.Txt';
  cFILENAME_LOGFILE_TCP_LICENSE_SERVICE     = 'LogFile_LicenseService.Txt';
  cFILENAME_LOGFILE_TCP_ACTIVATION_SERVICE  = 'LogFile_ActivationService.Txt';
  cFILENAME_CONNECTION_DUMPFILE             = 'ConnectionDumpFile.Txt';
  cFILENAME_DB_CONNECTION_CACHE             = 'DBConnectionCache.Txt';
  cFILENAME_ACCESS_CONTROL                  = 'AccessControl.Ini';
  cFILENAME_DB_CONNECTION_DUMPFILE          = 'DbConnectionDumpFile.Txt';
  cFILENAME_CLIENTDATASET_INIFILE           = 'ClientColumns.Ini';
  cFILENAME_ACTIVATION_INFO                 = 'ActivationInfo.Txt';

  // FeedBack Messages
  cFM_CONNECTION_STATS                      = 1000000;
  cFM_CONNECTION_MESSAGE                    = 1000001;
  //
  cFM_CONNECTION_GETDATA                    = 1000100;
  cFM_CONNECTION_SERVER_STATS               = 1000101;


  // Const String
  cSYSTEM_VERSION                           = 'Version';
  cSYSTEM_STARTTIME                         = 'StartTime';
  cSYSTEM_USERNAME                          = 'UserName';
  cSYSTEM_PASSWORD                          = 'Password';
  cSYSTEM_TOKEN                             = 'Token';
  cSYSTEM_MODULENAME                        = 'ModuleName';
  cSYSTEM_LOCALPID                          = 'LocalPID';
  //
  cLOCAL_CONNECTION_USERNAME                = 'UserName';
  cLOCAL_CONNECTION_MACHINEID               = 'MachineID';
  cLOCAL_CONNECTION_PEERIP                  = 'PeerIP';
  cLOCAL_CONNECTION_REASON                  = 'Reason';
  cLOCAL_CONNECTION_LOGINOK                 = 'LoginOK';
  //
  cSYSTEM_CON_PER_MINUTE                    = 'ConPerMinute';
  cSYSTEM_CMD_PER_MINUTE                    = 'CmdPerMinute';
  cSYSTEM_CON_PER_DAY                       = 'ConPerDay';
  cSYSTEM_CMD_PER_DAY                       = 'CmdPerDay';

  // Used with JSon format records when process User Connection Info
  cLOCAL_USERNAME                           = 'UserName';
  cLOCAL_PASSWORD                           = 'Password';
  cLOCAL_TOKEN                              = 'Token';
  //
  cLOCAL_FINGER_PRINT                       = 'FingerPrint';
  cLOCAL_SAGE_ACCOUNT_CODE                  = 'SageAccountCode';
  cLOCAL_SALES_NUMBER                       = 'SalesNumber';
  cLOCAL_PRODUCT_NAME                       = 'ProductName';
  cLOCAL_PRODUCT_VERSION                    = 'ProductVersion';
  cLOCAL_COMPUTER_NAME                      = 'ComputerName';
  cLOCAL_PRODUCT_MD5                        = 'ProductMD5';
  cLOCAL_RESULT                             = 'Result';

  // Activation Server params Client to Server and back (JSon format)
  //
  cACTIVATIONSERVER_MD5                     = 'MD5';
  cACTIVATIONSERVER_SAGE_ACCOUNT_NUMBER     = 'SageAccountNumber';
  cACTIVATIONSERVER_FINGER_PRINT            = 'FingerPrint';
  cACTIVATIONSERVER_RESULT_CODE             = 'ResultCode';
  cACTIVATIONSERVER_RESULT                  = 'Result';

  //
  cDBCACHE_MINCONNECTIONS                   = 'MinDBCacheSize';
  cDBCACHE_MAXCONNECTIONS                   = 'MaxDBCacheSize';
  cDBCACHE_PUSHTIMEOUT                      = 'PushTimeOut';
  cDBCACHE_POPTIMEOUT                       = 'PopTimeOut';
  cDBCACHE_COMMITONRELEASE                  = 'CommitOnRelease';
  cDBCACHE_AQUIRE_RETRY_COUNT               = 'AquireRetryCount';
  cDBCACHE_AQUIRE_SLEEP_MIN_PERIOD          = 'AquireRetryMinSleepPeriod';
  cDBCACHE_AQUIRE_SLEEP_MAX_PERIOD          = 'AquireRetryMaxSleepPeriod';
  cDBCACHE_AQUIRE_FREE_AFTER_N_MINUTES      = 'AquireFreeAfterNMinutes';
  cDBCACHE_THREAD_DEBUG                     = 'Debug';
  cDBCACHE_NEW_FREE_TEST                    = 'NewFreeTest';

  // Fields Names
  //
    fldLICENSE_ACTIVE                       = 'LICENSE_ACTIVE';


    fldCL_ACTIVE                            = 'CL_ACTIVE';
    fldCI_PK                                = 'CI_PK';
    fldCI_SAGE_ACCOUNT_NUMBER               = 'CI_SAGE_ACCOUNT_NUMBER';
    fldTS_USERNAME_EXISTS                   = 'TS_USERNAME_EXISTS';

    fldCL_EXPIRY_DATE                       = 'CL_EXPIRY_DATE';
    fldCL_EXPIRY_DATE_ACTIVE                = 'CL_EXPIRY_DATE_ACTIVE';
    fldCL_TOTAL_EMPLOYEES                   = 'CL_TOTAL_EMPLOYEES';
    fldCL_CONCURRENT_USERS                  = 'CL_CONCURRENT_USERS';
    fldCL_SALES_NUMBER                      = 'CL_SALES_NUMBER';
    fldCL_REGION                            = 'CL_REGION';
    //
    fldCI_IDX                               = 'CI_IDX';
    fldCI_AS_ACTIVATION_ENABLED             = 'CI_AS_ACTIVATION_ENABLED';

    fldCL_FK_SP_PK                          = 'CL_FK_SP_PK';

    fldSP_PRODUCT_NAME                      = 'SP_PRODUCT_NAME';
    fldSP_PRODUCT_VERSION                   = 'SP_PRODUCT_VERSION';
    fldSP_LICENSE_OPTIONS                   = 'SP_LICENSE_OPTIONS';
    fldSP_CATEGORY                          = 'SP_CATEGORY';

    fldEXTRA_PARAM_NAME                     = 'PARAM_NAME';
    fldEXTRA_PARAM_VALUE                    = 'PARAM_VALUE';

    fldCLA_PK                               = 'CLA_PK';
    fldCLA_ACTIVATED                        = 'CLA_ACTIVATED';
    fldCLA_FINGER_PRINT                     = 'CLA_FINGER_PRINT';
    fldCLA_COMPUTER_NAME                    = 'CLA_COMPUTER_NAME';

    fldBL_FINGER_PRINT                      = 'BL_FINGER_PRINT';

    fldUA_USERNAME                          = 'UA_USERNAME';
    fldUA_ACCOUNT_LOCKED                    = 'UA_ACCOUNT_LOCKED';
    fldUA_ACTIVE                            = 'UA_ACTIVE';
    fldUA_DELETED                           = 'UA_DELETED';

    fldREGION                               = 'REGION';

  // Inifile and Names of Value Pairs
  cCOMMON_COMMON_DIR                        = 'CommonDir';
  cCOMMON_VERBOSE_LEVEL                     = 'VerboseLevel';

  // JSON Database Action Commands and Fields
  cJSON_QUERY_NAME                          = 'QueryName';
  //JSONQUERY_NAME                          = 'QueryName';

  //Parameter Names
  cI_PK                                     = 'I_PK';
  cI_COMPANY_NAME                           = 'I_COMPANY_NAME';
  cI_SAGE_ACCOUNT_NUMBER                    = 'I_SAGE_ACCOUNT_NUMBER';
  cI_ACTIVE                                 = 'I_ACTIVE';
  cI_ONLYACTIVE                             = 'I_ONLYACTIVE';
  cI_ALLOW_ACTIVATIONS                      = 'I_ALLOW_ACTIVATIONS';

  cI_SALES_NUMBER                           = 'I_SALES_NUMBER';
  cI_PRODUCT_NAME                           = 'I_PRODUCT_NAME';
  cI_PRODUCT_VERSION                        = 'I_PRODUCT_VERSION';
  cI_PRODUCT_CATEGORY                       = 'I_PRODUCT_CATEGORY';
  cI_EXPIRY_DATE                            = 'I_EXPIRY_DATE';
  cI_EXPIRY_DATE_ACTIVE                     = 'I_EXPIRY_DATE_ACTIVE';
  cI_TOTAL_EMPLOYEES                        = 'I_TOTAL_EMPLOYEES';
  cI_CONCURRENT_USERS                       = 'I_CONCURRENT_USERS';
  cI_LAST_UPDATED                           = 'I_LAST_UPDATED';
  cI_REGION                                 = 'I_REGION';
  cI_PRODUCT_MD5                            = 'I_PRODUCT_MD5';
  //
  cI_SP_NOTES                               = 'I_SP_NOTES';
  cI_LICENSE_OPTIONS                        = 'I_LICENSE_OPTIONS';
  cI_JUST_NAME                              = 'I_JUST_NAME';
  cI_CATEGORY                               = 'I_CATEGORY';

  //
  cI_MD5                                    = 'I_MD5';
  cI_USERNAME                               = 'I_USERNAME';
  cI_PASSWORD                               = 'I_PASSWORD';
  cI_SALT                                   = 'I_SALT';
  cI_NEW_USERNAME                           = 'I_NEW_USERNAME';
  cI_LOCK                                   = 'I_LOCK';
  cI_DELETE                                 = 'I_DELETE';
  cI_MACHINEID                              = 'I_MACHINEID';
  cI_IP_ADDRESS                             = 'I_IP_ADDRESS';
  cI_REASON                                 = 'I_REASON';
  cI_LOGIN_OK                               = 'I_LOGIN_OK';
  cI_ACCOUNT_TYPE                           = 'I_ACCOUNT_TYPE';

  cSP_LOGUSERACCESS                         = 'LogUserAccess';
  cSP_INSUSER_INSUSER2                      = 'InsUser2';
  cSP_UPDUSER_LOCKACCOUNT                   = 'UpdUser_LockAccount';
  cSP_UPDUSER_RENAME                        = 'UpdUser_ReName';
  cSP_UPDUSER_SET_ACTIVE                    = 'UpdUser_SetActive';
  cSP_UPDUSER_SET_DELETED                   = 'UpdUser_SetDeleted';
  cSP_UPDUSER_SET_PASSWORD                  = 'UpdUser_SetPassword';
  //
  cSP_BATRCH_DAILYSTATS                     = 'Batch_DailyStats';


//  aSageAccountCode, aFingerPrint, aSalesNumber, aProductMD5, aComputerName



  cI_CLA_PK                                 = 'I_CLA_PK';

  cI_FINGER_PRINT                           = 'I_FINGER_PRINT';
  cI_COMPUTER_NAME                          = 'I_COMPUTER_NAME';
  //
  cI_BLACK_LIST_TYPE                        = 'I_BLACK_LIST_NAME';
  cI_SEARCH_STRING                          = 'I_SEARCH_STRING';
  //
  // Db Updates return codes
  cDB_API_OK                                    = 1000;   {OK}
  cDB_API_NO_ROW_FOUND                          = 1001;   {No Row Update}
  cDB_API_NO_TOO_MANY_ROWS_UPDATED              = 1002;   {Too Many Row updated}
  //
  cDB_CCRC_OK                                   = 1000;   {OK}
  cDB_CCRC_CUSTOMER_EXISTS                      = 1001;   {Customer Already Exists}
  cDB_CCRC_SAGE_EXISTS                          = 1002;   {Sage Account Number already Exists}
  cDB_CCRC_BOTH_EXIST                           = 1003;   {Both Exist}
  // Found in CheckSalesNumber
  cDB_CSNRC_OK                                  = 1000;   {OK}
  cDB_CSNRC_SALES_NUMBER_EXISTS                 = 1001;   {Sales Number Already Exists}

  // tCheckLicense:  License Actions Return Codes, these codes are return by the Stored Procedure
  // CheckLicense, must upadte and keep instep with any changes
  // decode values explained
  cLARC_OK                                      = 1000;   {OK}
  cLARC_NOT_FOUND                               = 1001;   {Finger Print & Sage Serial Number not Found}
  cLARC_NOT_ACTIVE                              = 1002;   {Found but not Active}
  cLARC_EXPIRED                                 = 1003;   {Found but Expired}
  cLARC_UPDATE_REQUIRED                         = 1004;   {Found & Update Required}
  cLARC_BLACKLISTED                             = 1005;   {BlackListed}
  cLARC_CUSTOMER_NOT_ACTIVE                     = 1006;   {Customer SAGE Account not Active}
  cLARC_AS_ACTIVATIONS_ALLOWED                  = 1007;   {AS Activation Disabled}
  //
  // tActivationResult: Return Codes from the Procedure
  // Update License Activations Return Codes, these codes are return by the Stored Procedure
  // must updated and keep instep with any changes
  //
  cDB_ULARC_OK                                  = 1000;   {OK}
  cDB_ULARC_RECORD_NOT_FOUND                    = 1001;   {Record Not Found}
  cDB_ULARC_LICENSE_NOT_ACTIVE                  = 1002;   {Found but not Active}
  cDB_ULARC_NO_LICENSE_AVAILABLE                = 1004;   {No Free License Available}
  cDB_ULARC_BLACKLISTED                         = 1005;   {BlackListed}
  cDB_ULARC_ACTIVATION_FAILED                   = 1006;   {Activation Failed}
  cDB_ULARC_PARAMETER_COMBINATION_NOT_FOUND     = 1007;   {I_SAGE_ACCOUNT_NUMBER, I_SALES_NUMBER and I_PRODUCT_MD5 conbination not found}
  cDB_ULARC_COMBINATION_ALREADY_ACTIVATED       = 1008;   {Parameter Combination has already been activated}
  cDB_ULARC_CUSTOMER_NOT_ACTIVE                 = 1009;   {Customer SAGE Account not Active}
  cDB_ULARC_AS_ACTIVATIONS_ALLOWED              = 1010;   {AS Activation Disabled}

  // DLL Exported Methods
  cDLL_AS_ACTIVATION                            = 'D7_Activation.Dll';
    cDLL_AS_SETUP                               = 'DLL_AS_Setup';
    cDLL_AS_FEEDBACK                            = 'DLL_AS_GetFeedBack';
    //
    cDLL_AS_CHECK                               = 'DLL_AS_CheckActivation';
    cDLL_AS_ACTIVATE                            = 'DLL_AS_Activate';
    cDLL_AS_GETLICENSE                          = 'DLL_AS_GetLicense';
    cDLL_AS_PING                                = 'DLL_AS_Ping';
    cDLL_AS_CLOSEDOWN                           = 'DLL_AS_CloseDown';

  // Actrivation Server, DLL's and Client Classes
  cAS_CLIENT_ENABLELOGGING                      = 'EnableLogging';
  //
  cAS_ACTIVE                                    = 'Active';
  cAS_EXPIRY_DATE                               = 'ExpiryDate';
  cAS_EXPIRY_ENABLED                            = 'ExpiryDateEnabled';
  cAS_TOTAL_EMPLOYEES                           = 'NumberExployees';
  cAS_TOTAL_USERS                               = 'TotalUsers';
  cAS_REGION                                    = 'Region';
  cAS_PRODUCT_NAME                              = 'ProductName';
  cAS_PRODUCT_VERSION                           = 'ProductVersion';
  cAS_LICENSE_OPTIONS                           = 'LicenseOptions';
  cAS_ALLOW_ACTIVATION                          = 'AllowActivation';

  // Account Type Constants
  cACCOUNT_TYPE_ACTIVATION_ACCOUNT              = 'A';
  cACCOUNT_TYPE_ACTIVATION_CLIENT               = 'C';
  cACCOUNT_TYPE_ACTIVATION_UNKNOWN              = 'H';

implementation

Uses {$IFDEF VER150}
     {$ELSE}
     TS_ServerUtilsU,
     {$ENDIF}
     MAS_FormatU;

Const
  cLOCAL_VERBOSE  = 'Verbose';
  cLOCAL_MESSAGE  = 'Message';
  //
{$IFDEF VER150}
{$ELSE}

{ tFourIntRec }

Procedure tFourIntegerRec.Clear;
begin
  Self.Int1 := 0;
  Self.Int2 := 0;
  Self.Int3 := 0;
  Self.Int4 := 0;
end;

{ tVerboseLevelRec }

Procedure tVerboseLevelRec.Clear;
begin
  Self.fVerboseLevel := vlNormal;
  Self.fMsg          := '';
end;

Procedure tVerboseLevelRec.SetValue (Const aMsg: String);
begin
  SetValue (vlNormal, aMsg);
end;
Procedure tVerboseLevelRec.SetValue (Const aValue: tTSVerboseLevel; Const aMsg: String);
begin
  Self.fVerboseLevel := aValue;
  Self.fMsg          := aMsg;
end;
Procedure tVerboseLevelRec.SetValue (Const aValue: tTSVerboseLevel; Const aFormat: String; Const Args: Array of Const);
begin
  SetValue (aValue, fnTS_Format (aFormat, Args));
end;
Procedure tVerboseLevelRec.SetValue (Const aFormat: String; Const Args: Array of Const);
begin
  SetValue (vlNormal, aFormat, Args);
end;

Procedure tVerboseLevelRec.FromJSon (Const aJSonString: tJSonString2);
var
  lvObj: tMASJSonObject;
begin
  lvObj := tMASJSonObject.Create (aJSonString);
  Try
    Self.fVerboseLevel := fnStrToVerboseLevel (lvObj.fnValueByName (cLOCAL_VERBOSE));
    Self.fMsg          := lvObj.fnValueByName (cLOCAL_MESSAGE);
  Finally
    lvObj.Free;
  End;
end;
Function tVerboseLevelRec.ToJSon: String;
begin
  Result := fnCreateJSon ([cLOCAL_VERBOSE, cLOCAL_MESSAGE], [fnVerboseLevelToStr (Self.fVerboseLevel) , Self.fMsg]);
end;

{ tUserInfoRec }

Procedure tUserInfoRec.Clear;
begin
  Username := '';
  Password := '';
  Token    := '';
end;

Procedure tUserInfoRec.SetValue (Const aUsername, aPassword: String);
begin
  Username := aUsername;
  Password := aPassword;
  Token    := '';
end;

Procedure tUserInfoRec.FromJSon (Const aJSonString: tJSonString2);
var
  lvObj: tMASJSonObject;
begin
  lvObj := tMASJSonObject.Create (aJSonString);
  Try
    Self.Username := lvObj.fnValueByName (cLOCAL_USERNAME);
    Self.Password := lvObj.fnValueByName (cLOCAL_PASSWORD);
    Self.Token    := lvObj.fnValueByName (cLOCAL_TOKEN);
  Finally
    lvObj.Free;
  End;
end;

Procedure tUserInfoRec.SetValue (Const aUsername, aPassword, aToken: String);
begin
  Username := aUsername;
  Password := aPassword;
  Token    := aToken;
end;

Function tUserInfoRec.ToJSon: String;
begin
  Result := fnCreateJSon ([cLOCAL_USERNAME, cLOCAL_PASSWORD, cLOCAL_TOKEN], [Username, Password, Token]);
end;

{ tUserLogon }

Procedure tUserLogon.Clear;
begin
  Self.OK := False;
  Self.UserInfo.Clear;
end;

Procedure tUserLogon.SetValue (Const aUsername, aPassword, aToken: String);
begin
  Self.OK := True;
  Self.UserInfo.SetValue (aUsername, aPassword, aToken);
end;

{ tTCPLogon }

Procedure tTCPLogon.Clear;
begin
  SetValue ('', '', '', 0);
end;

Procedure tTCPLogon.SetValue (Const aUrl, aUsername, aPassword: String; Const aPort: Integer);
begin
  Url      := aUrl;
  UserName := aUsername;
  Password := aPassword;
  Port     := aPort;
end;
{$ENDIF}

end.


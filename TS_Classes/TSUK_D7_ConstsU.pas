//
// Unit: TSUK_D7_ConstsU
// Author: M.A.Sargent  Date: 15/03/18  Version: V1.0
//
// Notes:
//
unit TSUK_D7_ConstsU;

interface

Uses Messages, SysUtils, MASRecordStructuresU, MAS_TypesU, TSUK_ConstsU, VerboseLevelTypeU;

Type
  tFourIntegerRec = Record
    Int1: Integer;
    Int2: Integer;
    Int3: Integer;
    Int4: Integer;
  End;

  tJSonString = String;

  // Event Defs
  tOnMessage     = Procedure (Const aVerboseLevel: tTSVerboseLevel; Const aMsg: String) of object;
  tOnWriteToLog  = Procedure (Const aTypeMsg: tTypeMsg; Const aName, aMessage: string) of Object;
  tOnWriteToJSon = Procedure (Const aCode: Integer; Const aJSonString: String) of object;


  tDbLogon = Record
    Url, Database, UserName, Password: String;
    Port: Integer;
  End;


  eHWC_Exception = Class (Exception);
  //e = class (eHWC_Exception);

  tAppMsg = (amNone, amCreateForm, amDestroyForm, amShutdown, amFrameCloseQry, amTest,
              amDatabaseOpened, amDatabaseChanged, amDatabaseClosed, amShowForm, amHideForm);

  tBulkCategories = (bcNone, bcCompany, bcDepartment, bcEmployees);
  // SetAmount = £5.00 Fixed +/- 0.50 Percentage +/- 10%
  tBulkChangeType = (ctNone, ctSetAmount, ctFixed, ctPercentage);
  tTSCurrencyRec = Record
    OK:       Boolean;
    Increase: Boolean;
    Value:    Currency;
  end;

  tBulkChangeRec = Record
    ShowOnlyChanged: Boolean;
    EffectiveDate:   tDateTime;
    BulkchangeType:  tBulkChangeType;
    Rate0:           tTSCurrencyRec;
    Rate1:           tTSCurrencyRec;
    Rate2:           tTSCurrencyRec;
    Rate3:           tTSCurrencyRec;
  end;

  TAbsenceType = (atNone, atEmpSick, atEmpHoliday, atEmpPaidLeave, atEmpUnPaidLeave, atGlobalStatutory,
                   atGlobalOther, atGlobalHoliday, atGlobalPaidLeave, atGlobalUnPaidLeave);

  tPayRollSystemsFormat = (psLoad, psfNameOnly, psfValuePair, psfMapList);

Const

  TAbsenceNames: array[atNone..atGlobalUnPaidLeave] of string = (
  '',
  'Sick',
  '%s',
  'Paid Absence',
  'UnPaid Absence',
  'Statutory %s',
  'Other',
  'Global %s',
  'Global Paid Absence',
  'Global UnPaid Absence');

    cDEFAULT_IP_ADDRESS                     = '127.0.0.1';
    //
    cTCP_ERROR_CONNECT_NOT_ACTIVE           = '10061';      // WSAECONNREFUSED

    //
    fldPMFN_FREQUENCY                       = 'PMFN_FREQUENCY';
    fldPMFN_FILENAME                        = 'PMFN_FILENAME';
    //
    fldTHIS_MACHINE                         = 'THIS_MACHINE';
    fldPM_FINGER_PRINT                      = 'PM_FINGER_PRINT';
    fldPM_NAME                              = 'PM_NAME';
    fldPM_NAME_1                            = 'PM_NAME_1';
    fldPM_ALLOW_ROAMING                     = 'PM_ALLOW_ROAMING';
    fldPM_LAST_HEARTBEAT                    = 'PM_LAST_HEARTBEAT';
    fldPM_ACTIVE                            = 'PM_ACTIVE';
    fldPM_HB_STATUS                         = 'PM_HB_STATUS';
    fldPM_INTERVAL                          = 'PM_INTERVAL';

    fldPMS_LEVEL1                           = 'PMS_LEVEL1';
    fldPMS_LEVEL2                           = 'PMS_LEVEL2';
    fldPMS_VALUE                            = 'PMS_VALUE';
    fldPMS_DATA_TYPE                        = 'PMS_DATA_TYPE';

    //
    fldPMD_PK                               = 'PMD_PK';
    fldPMD_FILENAME                         = 'PMD_FILENAME';
    fldPMD_LINE_COUNT                       = 'PMD_LINE_COUNT';
    fldPMD_ENTRY_DATE                       = 'PMD_ENTRY_DATE';

  // Inifile and Section Names
  //
  cINI_POLLING_SETTINGS                     = 'PollingSettings';
  cINI_SERVICE_SETTINGS                     = 'ServiceSettings';

  // Inifile and Names of Value Pairs
  //
  cCOMMON_COMMON_DIR                        = 'CommonDir';
  cCOMMON_VERBOSE_LEVEL                     = 'VerboseLevel';
  cCOMMON_VERBOSE_OUTPUT                    = 'VerboseOutput';

  cPOLLING_MAX_FILES                        = 'MaxFiles';
  cPOLLING_MAX_FILES_XP                     = 'MaxFilesXP';
  cPOLLING_SAFE_PATH                        = 'SafePath';
  cPOLLING_LOCKING_TYPE                     = 'LockingType';
  cPOLLING_WAIT_FOR_LOCK_SECONDS            = 'WaitForLockSeconds';
  cPOLLING_VERBOSE_LEVEL                    = 'VerboseLevel';
  cPOLLING_RAISE_FAILED_TO_DELETE           = 'RaiseFailedToDelete';
  cPOLLING_LOG_FAILED_TO_DELETE             = 'LogFailedToDelete';
  //
    cPOLLING_SAFE_PATH_DEFAULT              = 'polling\raw';
    cPOLLING_LOCKING_TYPE_DEFAULT           = 0;
    cPOLLING_WAIT_FOR_LOCK_SECONDS_DEFAULT  = 30;
    cPOLLING_VERBOSE_LEVEL_DEFAULT          = 1;
    
  // JSON Database Action Commands and Fields
  cJSON_QUERY_NAME                          = 'QueryName';
  //JSONQUERY_NAME                          = 'QueryName';


//  aSageAccountCode, aFingerPrint, aSalesNumber, aProductMD5, aComputerName



  cI_CLA_PK                                 = 'I_CLA_PK';


  cI_MSG_TYPE                               = 'I_MSG_TYPE';
  cI_FINGER_PRINT                           = 'I_FINGER_PRINT';
  cI_COMPUTER_NAME                          = 'I_COMPUTER_NAME';
  cI_LINE_NUMBER                            = 'I_LINE_NUMBER';
  cI_FILENAME                               = 'I_FILENAME';
  cI_ORIG_FILENAME                          = 'I_ORIG_FILENAME';
  cI_FREQUENCY                              = 'I_FREQUENCY';
  cI_LINES                                  = 'I_LINES';
  //
  cI_LEVEL1                                 = 'I_LEVEL1';
  cI_LEVEL2                                 = 'I_LEVEL2';
  cI_LEVEL3                                 = 'I_LEVEL3';
  cI_VALUE                                  = 'I_VALUE';
  //
  cI_BLACK_LIST_TYPE                        = 'I_BLACK_LIST_NAME';
  cI_SEARCH_STRING                          = 'I_SEARCH_STRING';
  //
  cI_NAME                                   = 'I_NAME';
  cI_DATA                                   = 'I_DATA';
  cI_MY_IP                                  = 'I_MY_IP';
  cI_DATE                                   = 'I_DATE';
  cI_STATUS                                 = 'I_STATUS';

  //
  cPOLLING_STATUS_SUSPECT                   = 'S';
  cPOLLING_STATUS_PROCESSED                 = 'P';
  cPOLLING_STATUS_NEW                       = 'N';
  cPOLLING_STATUS_EXCLUDED                  = 'E';

  //
  cPOLLING_MSG_MSG_TYPE_VERBOSE             = '"MSG_TYPE":"V"';
  cPOLLING_MSG_MSG_TYPE                     = 'MSG_TYPE';
  cPOLLING_MSG_NAME                         = 'NAME';
  cPOLLING_MSG_MESSAGE                      = 'MESSAGE';
  cPOLLING_MSG_FINGERPRINT                  = 'FINGERPRINT';
  cPOLLING_MSG_MYIP                         = 'MYIP';
  cPOLLING_MSG_DATE                         = 'DATE';
  //
  cPOLLING_MSG_TOCLIENT                     = 'SendToClient';

  //
  cDLL_D7_ACTIVATION                            = 'TSUK_ActivationClient.Dll';
    cDLL_D7_SETUP                               = 'DLL_D7_AS_Setup';
    cDLL_D7_FEEDBACK                            = 'DLL_D7_AS_GetFeedBack';
    //
    cDLL_D7_CHECK                               = 'DLL_D7_AS_CheckActivation';
    cDLL_D7_ACTIVATE                            = 'DLL_D7_AS_Activate';
    cDLL_D7_GETLICENSE                          = 'DLL_D7_AS_GetLicense';
    cDLL_D7_GETVALUE                            = 'DLL_D7_AS_GetValue';
    cDLL_D7_GETNAMEDVALUE                       = 'DLL_D7_AS_GetNamedValue';
    cDLL_D7_PING                                = 'DLL_D7_AS_Ping';
    cDLL_D7_CLOSEDOWN                           = 'DLL_D7_AS_CloseDown';

  // Activation Server, DLL's and Client Classes
  cCLIENT_ACTIVATIONSERVER_SETTINGS             = 'ClientSettings';
    cCAS_ENABLELOGGING                          = 'EnableLogging';

  cACTIVATION_SERVER_INFO                       = 'Info';
    cASI_MACHINE_NAME                           = 'MachineName';
    cASI_CREATION_DATE                          = 'CreationDate';
    cASI_LAST_VALIDATION_DATE                   = 'LastValidationDate';

  cACTIVATION_SERVER_SETTINGS                   = 'Activation';
    cASS_ACTIVE                                 = 'Active';
    cASS_EXPIRY_DATE                            = 'ExpiryDate';
    cASS_EXPIRY_ENABLED                         = 'ExpiryDateEnabled';
    cASS_TOTAL_EMPLOYEES                        = 'NumberExployees';
    cASS_TOTAL_USERS                            = 'TotalUsers';
    cASS_REGION                                 = 'Region';
    cASS_PRODUCT_NAME                           = 'ProductName';
    cASS_PRODUCT_VERSION                        = 'ProductVersion';
    cASS_LICENSE_OPTIONS                        = 'LicenseOptions';
    cAS_ALLOW_ACTIVATION                        = 'AllowActivation';

  //
  //
  cSP_CHK_POLLING_MACHINE                       = 'ChkPollingMachine';
  cSP_UPD_POLLING_MACHINE                       = 'UpdPollingMachine';
  cSP_INS_POLLING_MACHINE_LOG                   = 'InsPollingMachine_Log';

  cSP_DEL_POLLING_MACHINE_FILENAMES             = 'DelPollingMachine_FileNames';
  cSP_UPD_POLLING_MACHINE_FILENAMES             = 'UpdPollingMachine_FileNames';
  cSP_UPD_POLLING_MACHINE_SETTINGS              = 'UpdPollingMachine_Settings';
  //
  cSP_DEL_POLLINg_MACHINE_SINGLEFILENAME        = 'DelPollingMachine_SingleFileName';
  cSP_LOG_POLLING_MACHINE_HEARTBEAT             = 'LogPollingMachine_HeartBeat';
  //
  cSP_INS_POLLING_FILES                         = 'InsPollingMachine_Downloads';
  cSP_UPD_POLLING_FILES                         = 'UpdPollingMachine_Downloads';
  cSP_DEL_POLLING_FILES                         = 'DelPollingFiles';


  cI_DISPLAY_NAME                               = 'I_DISPLAY_NAME';
  cI_ALLOW_ROAMING                              = 'I_ALLOW_ROAMING';

  //
  //
  cLOCAL_CONFIG	                = 'CONFIG';
    cLC_IGNORE_MAPPING          = 'IGNORE_MAPPING';
  	cLC_INTERVAL                = 'INTERVAL';
    cLC_OLDSTYLE                = 'OLDSTYLE';
    cLC_ONLY_LOCAL_GUI          = 'ONLY_LOCAL_GUI';
    cLC_SHOW_POPUP              = 'SHOW_POPUP';

    // Alto
    cLC_KEY_PERSONNEL           = 'KeyPersonnel';
      cLC_KP_INTERVAL           = 'Interval';
      cLC_KP_SHOW_INONLY        = 'ShowInOnly';

  cDEBUG                        = 'Debug';
    cDEBUG_MIN_KP_REFRESH       = 'MinRefresh';
    cDEBUG_ENABLED_MIN_INTERVAL = 'EnableMinRefreshInterval';
    // Ini Debug File
    cDEBUG_AMPM_TEST            = 'AMPMDefault';  // 0 = AM 1 = PM

  // Polling Stats Info
  cNAME_FILES          = 'FILES';
  cNAME_LINES          = 'LINES';
  cNAME_TRANS          = 'TRANS';
  cNAME_FAILED         = 'FAILED';

  cTHIS_MACHINE        = 'This Machine';
  cmsgSELECT_A_MACHINE = 'Please Select a Machine';

  // Pipe Message Codes between Send and Client and visa vesa
  cPIPE_MSG_MSG               = 1000;
  cPIPE_MSG_HEARTBEAT_INFO    = 1001;
  cPIPE_MSG_HEARTBEAT_CLEAR   = 1002;
  cPIPE_MSG_HEARTBEAT_POLLNOW = 1003;
  cPIPE_MSG_JSON              = 1004;
  cPIPE_MSG_GET_SERVER_INFO   = 1005;
  cPIPE_MSG_SERVER_INFO       = 1006;

  // Polling Client Ini files names
  cPOLLING_CLIENT_CONFIG        = 'PollingClient';
    cPCC_POPUP_ON_ZERO_FILES    = 'PopupOnZeroFiles';

  //
  // Constants to deal with HardWare Controllers
  //
  cGeneralINISection              = 'settings';
    cGeneralINIFilename           = 'filename';
    cGeneralINIPollInterval       = 'pollinterval';
    cGeneralINIPollingEnabled     = 'PollingEnabled';
    cGeneralINIClearTrans         = 'cleartrans';
    cGeneralINIDefaultRaw         = 'UseAltRaw';
    cGeneralPlainToSee            = 'plain';
    cGeneralDefaultToV1SDK        = 'DefaultToV1SDK';

  cMaxTimerInterval               = 86400; // 000;  // 1 day
  cMinTimerInterval               = 15;    // 000;  // 15 Seconds
  cDEFAULT_15_MINUTES             = 900;   // 000;  // 15 Minutes

  //
  cHWC_COMMUNICATIONS_PORT        = 1551;
  cHWC_MUTEX_COMMS_NAME           = 'TCPMutex';
  cHWC_MUTEX_COMMS_ITEM           = 'TCPItem';

  // Directories
  cOUTPUT_DIR_ERRRORDUMP          = 'ErrorDump';
  cPATH_EMPLOYEE_TEMPLATE_DIR     = 'EmployeeTemplate';

  // Filenames
  cFILENAME_HWC_MONITOR           = 'HWCMonitor.Ini';
  cFILENAME_COMMON_INI            = 'HWCCommon.Ini';
  cFILENAME_TIMINGS_INI           = 'HWCTimings.Ini';
  cFILENAME_ERRORDUMP_FILE        = 'ErroDumpoFile.Txt';
  cFILENAME_ZKINIFILE             = 'ZKSettings.Ini';
  cPATH_EMPLOYEE_TEMPLATE_FILE    = 'employee_import.csv';

  //
  cFILENAME_CLIENTINIFILE         = 'FILENAME_CLIENTINIFILE';
  cFILENAME_SERVICEINIFILE        = 'FILENAME_SERVICEINIFILE';
  //
  cFILENAME_UNITS                 = 'FILENAME_UNITS';
  cFILENAME_ZKINI                 = 'FILENAME_ZKINI';
  cFILENAME_DOWNLOAD              = 'FILENAME_DOWNLOAD';
  cFILENAME_LOGFILE               = 'FILENAME_LOGFILE';
  cFILENAME_TIMINGS               = 'FILENAME_TIMINGS';
  cFILENAME_ERROR_DUMP            = 'FILENAME_ERROR_DUMP';
  cHWC_SERVICE_NAME               = 'HWCServiceName';
    cHWC_SERVICE_NAME_DEF_NAME    = 'HWCService';


  // Ini file entries
  cINI_HWC_COMMON                 = 'HWC_CommonSettings';
    cIHC_INI_FILENAME             = 'IniFileName';
    cIHC_INI_UNITS_FILENAME       = 'UnitsFileName';
    cIHC_INI_TIMING_FILENAME      = 'TimingFileName';
    cIHC_INI_SERVICE_NAME         = 'ServerName';
    cIHC_INI_SERVICE_LOGFILENAME  = 'ServerLogFileName';

  cINI_HWC_SERVICES               = 'HWC_Services';

  cINI_HWC_MONITOR                   = 'HWC_Monitor';
    cIHM_OUTPUT_OK                   = 'OutputOK';
    cIHM_RESTART_AFTER_N_MINUTES     = 'RestartMinutes';
    cIHM_RESTART_DISABLED            = 'RestartDisabled';
  cINI_HWC_SERVICE_RESTART_DISABLED  = 'ServiceRestartDisabled';

  cINI_HWC_CLIENT_SETTINGS               = 'HWCClientSettings';
    cIHCS_MIN_POLLING_INTERVAL           = 'MinInterval';
    cIHCS_MAX_POLLING_INTERVAL           = 'MaxInterval';
    cIHCS_MAX_CLOCK_DIFF_IN_SECONDS      = 'MaxClockDiff';
    cIHCS_ENABLE_PERIODIC_TIMER          = 'EnablePeriodicTimer';
    cIHCS_ENABLE_PERIODIC_TIMER_INTERVAL = 'EnablePeriodicTimerInterval';
    cIHCS_ENABLE_SUB_MINUTE_INTERVAL     = 'SubOneMinuteInterval';
    cIHCS_WARN_ON_BUSY_COUNT             = 'WarnOnBusyCount';

  cINI_HWC_SETTINGS                  = 'Settings';
    cIHS_APPNAME                     = 'AppName';
    cIHS_TEMPLATES_ENABLED           = 'TemplatesEnabled';
    cIHS_MSG_QUEUE_POLLING_INTERVAL  = 'QueuePollingInterval';
    cIHS_AUTO_POLLING_ON_STARTUP     = 'DownLoadOnStartup';
    cIHC_INI_MAX_TIMING_ENTRIES      = 'MaxTimingEntries';

  cINI_HWC_TCP_CLIENT             = 'TCP_Client';
    cINI_HTC_HOST                 = 'Host';
    cINI_HTC_PORT                 = 'Port';
    cINI_HTC_CONNECT_TIMEOUT      = 'ConnectTimeOut';
    cINI_HTC_RECEIVE_TIMEOUT      = 'RecieveTimeOut';
    cINI_HTC_RETRY_TIMEOUT        = 'RetryTimeOut';
    cINI_HTC_LOOP_SLEEP_PERIOD    = 'SleepPeriod';

  cINI_COMMAND_REPLY_OVERRIDES    = 'CommandOverRides';
    cINI_CRO_CMD_ID               = 'CMD_%d';

  //
  cZK_INI_SETTINGS                    = 'ZK_Settings';
    cZIS_DISCONNECT_EVERY_TIME        = 'DisConnectEveryTime';
    cZIS_SUCCESS_FEEDBACK             = 'SuccessFeedBack';
    cZIS_STOP_AFTER_ERROR             = 'StopAfterError';
    cZIS_ECHO_TIMEOUT                 = 'EchoTimeOut';
    cZIS_ECHO_ENABLED                 = 'EchoEnabled';
    cZIS_ECHO_B4_CONNECT              = 'EchoBeforeConnect';
    cZIS_ECHO_B4_CONNECT_TIMEOUT      = 'EchoBeforeConnectTimeOut';
    cZIS_ECHO_B4_CONNECT_LOG_FAILURES = 'EchoBeforeConnectLogFailures';

  cINI_HWC_SERVICE_THREAD             = 'ServiceThreadSettings';
    cIHST_INTERVAL                    = 'Interval';
    cIHST_PRIORITY                    = 'Priority';
    cIHST_HOURLY_MAX_EXCEPTIONS       = 'HourlyMax';

  cINI_SWIPER32_CONFIG                = 'Settings';
    cISC_EMPLOYEE_TEMPLATE_DIR        = 'EmployeeTemplateDir';
    cISC_EMPLOYEE_TEMPLATE_FILE       = 'EmployeeTemplateFile';

  // Pipe Commands

  cHWC_CMD_ALLUNITS           = 'ALL';
  //
  cHWC_CMD_REPLY_OK             = 1000;
  cHWC_CMD_REPLY_ERR            = 1001;
  cHWC_CMD_REPLY_NOFEEDBACK     = 1002;
  cHWC_CMD_REPLY_COMPLETED      = 1003;
  cHWC_CMD_REPLY_INFO           = 1004;
  cHWC_CMD_REPLY_BUSY           = 1005;
  //
   //array [1..Elements] of string = ('element 1','element 2','element 3');
  cHWC_CMD_REPLY_SUBMIT       : Array [0..1] of SmallInt = (cHWC_CMD_REPLY_OK, cHWC_CMD_REPLY_BUSY);
  //cHWC_CMD_REPLY_ALL_OK       : Array [0..1] of SmallInt = (cHWC_CMD_REPLY_OK, cHWC_CMD_REPLY_INFO);
  cHWC_CMD_REPLY_ALL          : Array [0..5] of SmallInt = (cHWC_CMD_REPLY_OK, cHWC_CMD_REPLY_ERR, cHWC_CMD_REPLY_NOFEEDBACK, cHWC_CMD_REPLY_COMPLETED, cHWC_CMD_REPLY_INFO, cHWC_CMD_REPLY_BUSY);


  cHWC_CMD_ABOUTINFO          = 10050;     // Get the System Status
  cHWC_CMD_HEARTBREAT         = 10051;     // HeartBeat
  cHWC_CMD_FEEDBACK           = 10052;     //
  cHWC_CMD_STATUS             = 10053;     //
  //
  cHWC_CMD_BASE               = 10100;
  cHWC_CMD_SETDATETIME        = 10101;
  //cHWC_CMD_SETPASSWORD        = 10102;   // Not Used, GUI command
  cHWC_CMD_GETTEMPLATE        = 10103;
  cHWC_CMD_SETTEMPLATE        = 10104;
  cHWC_CMD_TEST               = 10105;
  cHWC_CMD_BACKUP_UNIT        = 10106;
  cHWC_CMD_RESTORE_UNIT       = 10107;
  cHWC_CMD_GETPARAMS          = 10108;
  cHWC_CMD_DOWNLOADDATA       = 10109;
  cHWC_CMD_RELOAD_UNITS       = 10110;
  cHWC_CMD_RESTART_UNITS      = 10111;
  cHWC_CMD_CLEAR_ADMIN        = 10112;
  // Remember to update the fnCmdToDesc Function

  // Commands used in the SDK GetDeviceStatus command, values obtained from the SDK documention
  // GETDEVICESTATUS

  cZK_SDK_NO_ADMIN_ACCOUNTS           = 1;     // 1 Number of administrators
  cZK_SDK_NO_USER_ACCOUNTS            = 2;     // 2 Number of registered users
  cZK_SDK_NO_USER_FP_TEMPLATES        = 3;     // 3 Number of fingerprint templates on the machine
  cZK_SDK_ATTENDANCE_RECORDS          = 6;     // 6 Number of attendance records
  cZK_SDK_NO_USER_FP_CAPACITY         = 7;     // 7 Fingerprint template capacity
  cZK_SDK_NO_USER_CAPACITY            = 8;     // 8 User capacity
  cZK_SDK_ATTENDANCE_CAPACITY         = 9;     // 9 Attendance record capacity
  cZK_SDK_REMAIN_FP_TEMPLATE_CAPACITY = 10;    // 10 Remaining fingerprint template capacity
  cZK_SDK_REMAIN_USER_CAPACITY        = 11;    // 11 Remaining fingerprint template capacity
  cZK_SDK_REMAIN_ATTENDANCE_CAPACITY  = 12;    // 12 Remaining attendance records

  // HWC Control Param Names
  cHWC_PARAMS_COMMAND_CODE    = 'CmdCode';
  cHWC_PARAMS_TERMINAL_NAME   = 'TerminalName';
  cHWC_PARAMS_FILE_NAME       = 'FileName';
  cHWC_PARAMS_NAME            = 'StringName';
  cHWC_PARAMS_RETURN_MESSAGE  = 'Message';
  cHWC_PARAMS_AUTO_POLLING    = 'AutoPolling';

  //
  cHWC_PARAMS_SHORT_NAME      = 'ShortName';
  cHWC_PARAMS_CONNECTION_TYPE = 'ConnectionType';
  cHWC_PARAMS_COM_BAUD        = 'ComBaud';
  cHWC_PARAMS_COM_PORT        = 'ComPort';
  cHWC_PARAMS_MACHINE_NUMBER  = 'MachineNumber';
  cHWC_PARAMS_MODEM_NUMBER    = 'ModemNumber';
  cHWC_PARAMS_MODEM_INIT_STR  = 'ModemInitStr';
  cHWC_PARAMS_IP_ADDR         = 'IPAddr';
  cHWC_PARAMS_IP_PORT         = 'IPPort';
  cHWC_PARAMS_MODEL_TYPE      = 'ModelType';
  cHWC_PARAMS_RESTART_AFTER   = 'RestartAfter';
  cHWC_PARAMS_SERIAL_NUMBER   = 'SerialNumber';
  cHWC_PARAMS_USE_OLD_V1_SDK  = 'UseOldV1SDK';
  cHWC_PARAMS_RESTART_PERIOD  = 'RestartPeriod';


  cHWC_FEEDBACK_ACTION        = 'Action';
  cHWC_FEEDBACK_NAME          = 'Name';
  cHWC_FEEDBACK_FEEDBACK      = 'FeedBack';
  //cHWC_FEEDBACK_FEEDBACK1     = 'FeedBack1';

  //
  cSTATS_SERVER_STARTTIME         = 'StartTime';
  cSTATS_SERVER_UPTIME            = 'UpTime';
  cSTATS_SERVER_VERSION           = 'Version';
  cSTATS_SERVER_PATH              = 'Path';
  cSTATS_SERVER_EXENAME           = 'ExeName';

  // GetDeviceStatus descriptions
  cDEVICE_STATUS_ADMIN_ACCOUNTS              = 'AdminAcounts';
  cDEVICE_STATUS_USER_ACCOUNTS               = 'UserAccounts';
  cDEVICE_STATUS_USER_FP_TEMPLATES           = 'FP_Templates';
  cDEVICE_STATUS_ATTENDANCE_RECORDS          = 'AttendanceRecords';
  cDEVICE_STATUS_NO_USER_FP_CAPACITY         = 'FP_Capacity';
  cDEVICE_STATUS_NO_USER_CAPACITY            = 'UserCapacity';
  cDEVICE_STATUS_ATTENDANCE_CAPACITY         = 'AttendanceCapacity';
  cDEVICE_STATUS_REMAIN_FP_TEMPLATE_CAPACITY = 'RemainFPCapacity';
  cDEVICE_STATUS_REMAIN_USER_CAPACITY        = 'RemainUserCapacity';
  cDEVICE_STATUS_REMAIN_ATTENDANCE_CAPACITY  = 'RemainAttendanceCapacity';

  //
  cHWC_STATS_LAST_COMMAND         = 'LastCommand';
  cHWC_STATS_LAST_COMMAND_WHEN    = 'LastCommandDate';
  cHWC_STATS_LAST_COLLECTION_UNIT = 'LastCollectionUnit';
  cHWC_STATS_LAST_COLLECTION_WHEN = 'LastCollectionDate';

  //cHWC_PARAMS_SERIAL_NUMBER       = 'SerialNumber';
  cHWC_PARAMS_CLOCK_DATE          = 'ClockDate';
  cHWC_PARAMS_PRODUCTCODE         = 'ProductCode';
  cHWC_PARAMS_FIRMWARE_VERSION    = 'FirmwareVersion';
  cHWC_PARAMS_SDK_VERSION         = 'SDKVersion';
  cHWC_PARAMS_MAC_ADRESS          = 'MACAddress';

  // Please Wait and Feedback Screen Messages Constants
  cPLEASEWAIT_CREATE         = 1000;
  cPLEASEWAIT_PROGRESS       = 1001;
  cPLEASEWAIT_MSG            = 1002;
  cPLEASEWAIT_FREE           = 1003;
  //
  cPLEASEWAIT_CREATE_SETUP   = 1004;
  cPLEASEWAIT_PROGRESS_COUNT = 1005;

  //
  cPLEASE_WAIT_LOAD_BULKPAYRATES      = 1;
  cPLEASE_WAIT_SAVE_BULKPAYRATES      = 2;
  cPLEASE_WAIT_VALIDATE_EMPLOYEE_IMP  = 3;
  cPLEASE_WAIT_SAVE_EMPLOYEE_IMP      = 4;


  //
  // Windows Messages
  //
  cUM_BASE_LEVEL_ADJ                 = 0;
  cUM_BASE_LEVEL                     = WM_USER + cUM_BASE_LEVEL_ADJ;
  //
  um_PleaseWait_Msg                  = (cUM_BASE_LEVEL + 1000);
  um_IniInfoChanged_Msg              = (cUM_BASE_LEVEL + 1001);
  //
  um_TellFramesParentFormingClosing  = (cUM_BASE_LEVEL + 8010);
  um_FrameCreatedTellParentForm      = (cUM_BASE_LEVEL + 8011);
  um_FrameMsg                        = (cUM_BASE_LEVEL + 8012);
  um_AfterConstructor                = (cUM_BASE_LEVEL + 8013);
  //
  um_ABSDatesetEvent                 = (cUM_BASE_LEVEL + 10000);
  //
  um_TSEvent_KeyPersonnelChanges     = (cUM_BASE_LEVEL + 10100);
  um_TSEvent_EmployeesChanged        = (cUM_BASE_LEVEL + 10101);  // currently posted after a Bulk Emplyee Import
  um_TSEvent_PayRollSystemChanged    = (cUM_BASE_LEVEL + 10102);  // currently postedif PayRoll System changes

  // Message Return Values
  cMSGOK                     = 0;
  cCLOSEQRY_CHANGESPENDING   = 200000;

  //
  // FieldNames use in Alto
  //
  cCMD_UPDATE_TYPE                            = 'UPDATEKIND';
  //
  cFLD_EMP_NAME                               = 'Name';
  cFLD_EMP_HASPAYRATE                         = 'HasPayRate';
  cFLD_EMP_PAYROLL_SYSTEM                     = 'PayRollSystem';


  cFLD_COMPANY_NAME                           = 'Company Name';

  cFLD_DEPT_DEPNUMBER                         = 'DEPNUMBER';
  cFLD_DEPT_DEPNAME                           = 'DEPNAME';

  cFLD_IO_NAME                                = 'Name';
  cFLD_IO_AS_DATETIME                         = 'AsDateTime';
  cFLD_IO_TIME                                = 'Time';
  cFLD_IO_INTDATE                             = 'IntDate';
  cFLD_IO_INOUT_STATUS                        = 'Status';
  cFLD_IO_LASTUPDATED                         = 'Last Status Time';
  cFLD_IO_LASTTRANSDATETIME                   = 'LastTransDateTime';
  cFLD_IO_INT_TIME                            = 'INTTIME';
  cFLD_IO_DAYS_SINCE                          = 'DaysSince';
  cFLD_IO_DISPLAYNAME                         = 'DspName';
  cFLD_IO_ABSENCESTATUS                       = 'AbsenceStatus';
  //
  cFLD_IO_DSP_STATUS                          = 'dspStatus';
  cFLD_IO_DSP_ABSENCESTATUS                   = 'dspAbsenceStatus';

  cFLD_PAY_RATES_NAME                         = 'NAME';
  cFLD_PAY_RATES_EFFECTIVE_DATE               = 'EFFECTIVEDATE';
  cFLD_PAY_RATES_JUST_EFFECTIVE_DATE          = 'JustEffectiveDate';
  cFLD_PAY_RATES_VALID_UNTIL                  = 'VALID_UNTIL';
  cFLD_PAY_RATES_RATE0                        = 'STANDARDRATE';
  cFLD_PAY_RATES_RATE1                        = 'RATE1';
  cFLD_PAY_RATES_RATE2                        = 'RATE2';
  cFLD_PAY_RATES_RATE3                        = 'RATE3';
  cFLD_PAY_RATES_RATE0_NEW                    = 'dspStandardRateNew';
  cFLD_PAY_RATES_RATE1_NEW                    = 'dspRate1New';
  cFLD_PAY_RATES_RATE2_NEW                    = 'dspRate2New';
  cFLD_PAY_RATES_RATE3_NEW                    = 'dspRate3New';
  //

  cFLD_LUC_LEVEL3                             = 'Level3';
  cFLD_LUC_DATA                               = 'Data';

  // Common Column Names
  cFLD_ACTIVE                                 = 'Active';
  cFLD_TOTAL                                  = 'Total';
  cFLD_DISABLED                               = 'Disabled';
  cFLD_FREE                                   = 'Free';
  cFLD_MAX                                    = 'Max';
  cFLD_MAX_VALUE                              = 'MAX_VALUE';

  cFLD_DEPARTMENT_DEPNUMBER                   = 'DepNumber';
  cFLD_DEPARTMENT_DEPNAME                     = 'DepName';

  // Field used by Employee Import Process
  cFLD_TMP_NAME                               = 'Name';
  cFLD_TMP_FIRSTNAME                          = 'First Name';
  cFLD_TMP_LASTNAME                           = 'Last Name';
  cFLD_TMP_UNIQUE_REF                         = 'Unique ID';    // is Card ID in the Database
  cFLD_TMP_PAYROLL_REF                        = 'Payroll Ref';  // is EmpNumber in the Database
  cFLD_TMP_COMPANY                            = 'Company';
  cFLD_TMP_DEPARTMENT                         = 'Department';
  cFLD_TMP_DEPNUMBER                          = 'DepNumber';
  cFLD_TMP_VALIDATED                          = 'Validated';
  //
  cFLD_TMP_JOB_TITLE                          = 'JOB TITLE';
  cFLD_TMP_HOME_TELEPHONE                     = 'Home Phone';
  cFLD_TMP_MOBILE_PHONE                       = 'Mobile Phone';
  cFLD_TMP_EMAIL_ADDRESS                      = 'Email Address';
  cFLD_TMP_EMERGENCY_CONTACT_NO               = 'Emergency Contact No';
  cFLD_TMP_EMERGENCY_CONTACT_DESC             = 'Emergency Contact Desc';
  cFLD_TMP_ACTIVE                             = 'ACTIVE';
  cFLD_TMP_ADDRESS1                           = 'Home Address 1';
  cFLD_TMP_ADDRESS2                           = 'Home Address 2';
  cFLD_TMP_ADDRESS3                           = 'Home Address 3';
  cFLD_TMP_ADDRESS4                           = 'Home Address 4';
  cFLD_TMP_POSTCODE                           = 'Home Address 5';
  cFLD_TMP_NI_NUMBER                          = 'NI/SS Number';
  cFLD_TMP_START_DATE                         = 'Start Date';

  // Alto Table Names
  cLOCAL_TABLE_IOBOARD                        = 'LAD';

  cLOCAL_INDEX_NAME                           = 'Name';

  cMAIN_TABLE_EMPTABLE                        = 'EmpDets';
  cMAIN_TABLE_COMPANY                         = 'Company';
  cMAIN_TABLE_DEPARTMENT                      = 'Dept';

  //
  // Alto Data Values
  //
  cLUC_PAYRATES                               = 'PAYRATES';
  cLUC_PAYRATES_STANDARD                      = 'STANDARD';
  cLUC_PAYRATES_RATE1                         = 'RATE1';
  cLUC_PAYRATES_RATE2                         = 'RATE2';
  cLUC_PAYRATES_RATE3                         = 'RATE3';

  cPAYRATE_EMP_RECORD                         = 1;
  cPAYRATE_TEMPLATE_RECORD                    = 2;

  cBULKPAYRATE_COMPANY_RECORD                 = 1;
  cBULKPAYRATE_DEPARTMENT_RECORD              = 2;
  cBULKPAYRATE_EMPLOYEES_RECORD               = 3;

  cTRANSACTION_OUT                            = 0;
  cTRANSACTION_IN                             = 1;
  // Not a Trans table value used by IOBoard in Swipe32 to display old Transactions
  cTRANSACTION_OUT_OLD                        = 2;
  cTRANSACTION_IN_OLD                         = 3;

  cUnknownLADCategory                         = 99;

  //
  //cI_NAME                                     = 'I_NAME';
  cI_RECTYPE                                  = 'I_RECTYPE';
  //cI_DATA                                     = 'I_DATA';
  cI_ACTIVE                                   = 'I_ACTIVE';
  cI_EFFECTIVE_DATE                           = 'I_EFFECTIVE_DATE';
  cI_INONLY                                   = 'I_INONLY';
  cI_CARDID                                   = 'I_CARDID';
  cI_EMP_NUMBER                               = 'I_EMP_NUMBER';
  cI_COMPANY_NAME                             = 'I_COMPANY_NAME';
  cI_DEPNAME                                  = 'I_DEPNAME';
  cI_PAYROLL_SYSTEM                           = 'I_PAYROLL_SYSTEM';
  //
  cI_ID                                       = 'ID';


  // Moved from frmMain
  cCompany         = 'Company';
  cCompanies       = 'Companies';
  cDepartment      = 'Department';
  cDepartments     = 'Departments';
  cEmployee        = 'Employee';
  cEmployees       = 'Employees';

  //
  // SQL Constants
  //
  //cSQL_EMPLOYEE_EXISTS                         = 'EMPLOYEE_EXISTS';
  cSQL_EMPLOYEE_ACTIVE                         = 'EMPLOYEE_ACTIVE';
  cSQL_CARDID_EXISTS                           = 'CARDID_EXISTS';
  cSQL_PAYROLL_REF_EXISTS                      = 'PAYROLL_REF_EXISTS';
  cSQL_ALL_COMPANYIES                          = 'ALL_COMPANYIES';
  cSQL_ALL_DEPARTMENTS                         = 'ALL_DEPARTMENTS';
  cSQL_MAX_DEPNUMBER                           = 'MAX_DEPNUMBER';
  cSQL_PAYROLL_REF_SYSTEM                      = 'PAYROLL_SYSTEM';
  cSQL_PAYROLL_REF_DELETE                      = 'PAYROLL_DELETE';
  cSQL_PAYROLL_REF_INSERT                      = 'PAYROLL_INSERT';
  cSQL_LOOKUP_CODES                            = 'LOOKUP_CODES';
  cSQL_DEL_IOBOARD                             = 'DEL_IOBOARD';
  cSQL_QRY_EMP_PAYRATE                         = 'QRY_EMP_PAYRATE';
  //
  cSQL_DEL_EMPLOYEE                            = 'DEL_EMPLOYEE';  
  cSQL_DEL_RULE_ASSIGNMENT                     = 'DEL_RULE_ASSIGNMENT';
  cSQL_DEL_SHIFT_ASSIGNMENT                    = 'DEL_SHIFT_ASSIGNMENT';
  cSQL_DEL_WORKP_ASSIGNMENT                    = 'DEL_WORKP_ASSIGNMENT';
  //
  cSQL_DEL_PAY_PERIOD                          = 'DEL_PAY_PERIOD';
  cSQL_DEL_PAY_PERIOD_ASSG                     = 'DEL_PAY_PERIOD_ASSG';
  //
  cSQL_QRY_EMP_ABSENCE_DATES                   = 'QRY_ABSENCE_DATES';

  // Validation Checks for GUI, moved from Magic numbers to Constants
  cGUI_UNIQUE_ID_MAX_VALUE                     = 999999999;      //
  cGUI_UNIQUE_ID_MAX_DIGITS                    = 9;      //

  // Lookup Codes
  cLUC_SETTINGS                                = 'SETTINGS';
  //
  cLUC_PAYROLL_SYSTEMS                         = 'PAYROLL';

  // PayRoll Systems
  cPAYROLL_SYSTEMS_1                           = 1;
  cPAYROLL_SYSTEMS_2                           = 2;

  // Employee Absence Values
  cABSENCE_NONE            = 0;
  cABSENCE_SICK            = 1;
  cABSENCE_HOLIDAY         = 2;
  cABSENCE_PAIDLEAVE       = 3;
  cABSENCE_UNPAIDLEAVE     = 4;
  //
  cABSENCE_GBL_STATUTORY   = 5;
  cABSENCE_GBL_OTHER       = 6;
  cABSENCE_GBL_HOLIDAY     = 7;
  cABSENCE_GBL_PAIDLEAVE   = 8;
  cABSENCE_GBL_UNPAIDLEAVE = 9;

  cFLD_ABSENCE_RECORDTYPE                      = 'RecordType';
  cFLD_ABSENCE_EMPNAME                         = 'EmpName';
  cFLD_ABSENCE_TRANSTYPE                       = 'TransType';
  cFLD_ABSENCE_AM                              = 'AM';
  cFLD_ABSENCE_PM                              = 'PM';

  //
  Function fnStrToLicenseOptions        (Const aLicenseOptions: String): tLicenseOptions;
  Function fnLicenseOptionsToStr        (Const aLicenseOptions: tLicenseOptions): String;
  //
  Function fnStrToTimeSystemsRegions    (Const aTimeSystemsRegions: String): tTimeSystemsRegions;
  Function fnTimeSystemsRegionsToStr    (Const aTimeSystemsRegions: tTimeSystemsRegions): String;

  Function fnPollingFileTypeToDbValue   (Const aPollingFileType: tPollingFileType): String;
  // tMsgType = (mtInformation, mtWarning, mrError, mtException, mtCritical);
  Function fnDbValueToTypeMsg           (Const aTypeMsg: string): tTypeMsg;
  Function fnTypeMsgToDbValue           (Const aTypeMsg: tTypeMsg): String;
  Function fnTypeMsgToDescription       (Const aTypeMsg: tTypeMsg): String;
  //
  Function fnPollingFileStatusToDbValue (Const aValue: tPollingFileStatus): String;

  Function fnVerboseLevelToInt          (Const aValue: tTSVerboseLevel): Integer;
  Function fnVerboseLevelToStr          (Const aValue: tTSVerboseLevel): String;
  Function fnIntToVerboseLevel          (Const aValue: Integer): tTSVerboseLevel;
  Function fnStrToVerboseLevel          (Const aValue: String): tTSVerboseLevel;
  Function fnVerboseLevelToDescription  (Const aValue: tTSVerboseLevel): String;
  //
  Function fnCmdToDesc                  (Const aCommand: Integer): String;
  //
  Function fnAbsenceTypeToInt           (Const aValue: tAbsenceType): Integer;
  Function fnIntToAbsenceType           (Const aValue: Integer): tAbsenceType;

implementation

Uses MAS_FormatU, MASCommonU, MAS_ConstsU;

Const
  cLOCAL_VERBOSE  = 'Verbose';
  cLOCAL_MESSAGE  = 'Message';
  //


// Routine: fnStrToLicenseOptions
// Author: M.A.Sargent  Date:15/05/18  Version: V1.0
//
// Notes:
// tLicenseOptions = (loUnKnown, loLicenseServer, loDeskTop, loSpare1, loSpare2);
//
Function fnStrToLicenseOptions (Const aLicenseOptions: String): tLicenseOptions;
begin
  if      IsEqual (aLicenseOptions, 'U') then Result := loUnKnown
  else if IsEqual (aLicenseOptions, 'L') then Result := loLicenseServer
  else if IsEqual (aLicenseOptions, 'A') then Result := loDeskTop
  else if IsEqual (aLicenseOptions, 'Z') then Result := loSpare1
  else if IsEqual (aLicenseOptions, 'Y') then Result := loSpare2
  else Raise Exception.CreateFmt ('Error: fnStrToLicenseOptions. Unknown values passed to routine (%s)',[aLicenseOptions]);
end;
Function fnLicenseOptionsToStr (Const aLicenseOptions: tLicenseOptions): String;
begin
  Case aLicenseOptions of
    loUnKnown:       Result := 'U';
    loLicenseServer: Result := 'L';
    loDeskTop:       Result := 'A';
    loSpare1:        Result := 'Z';
    loSpare2:        Result := 'Y';
    else Raise Exception.CreateFmt ('Error: fnLicenseOptionsToStr. Unknown values passed to routine (%d)',[Ord (aLicenseOptions)]);
  end;
end;

// Routine: fnStrToTimeSystemsRegions
// Author: M.A.Sargent  Date:15/05/18  Version: V1.0
//
// Notes:
// tTimeSystemsRegions = (tsrAll, tsrUK, tsrUSA, tsrSpanish);
//
Function fnStrToTimeSystemsRegions (Const aTimeSystemsRegions: String): tTimeSystemsRegions;
begin
  if      IsEqual (aTimeSystemsRegions, 'ALL')     then Result := tsrAll
  else if IsEqual (aTimeSystemsRegions, 'UK')      then Result := tsrUK
  else if IsEqual (aTimeSystemsRegions, 'USA')     then Result := tsrUSA
  else if IsEqual (aTimeSystemsRegions, 'SPANISH') then Result := tsrSpanish
  else Raise Exception.CreateFmt ('Error: fnStrToTimeSystemsRegions. Unknown values passed to routine (%s)',[aTimeSystemsRegions]);
end;
Function fnTimeSystemsRegionsToStr (Const aTimeSystemsRegions: tTimeSystemsRegions): String;
begin
  Case aTimeSystemsRegions of
    tsrAll:     Result := 'ALL';
    tsrUK:      Result := 'UK';
    tsrUSA:     Result := 'USA';
    tsrSpanish: Result := 'SPANISH';
    else Raise Exception.CreateFmt ('Error: fnTimeSystemsRegionsToStr. Unknown values passed to routine (%d)',[Ord (aTimeSystemsRegions)]);
  end;
end;

// Routine: fnPollingFileTypeToDbValue
// Author: M.A.Sargent  Date:15/05/18  Version: V1.0
//
// Notes:
// tPollingFileType = (pftEveryTime, pftJustOnce);
//
Function fnPollingFileTypeToDbValue (Const aPollingFileType: tPollingFileType): String;
begin
  Case aPollingFileType of
    pftEveryTime: Result := 'E';
    pftJustOnce:  Result := 'O';
    else Raise Exception.CreateFmt ('Error: fnPollingFileTypeToDbValue. Unknown values passed to routine (%d)',[Ord (aPollingFileType)]);
  end;
end;

// Routine: fnDbValueToMsgType, fnMsgTypeToDbValue & fnMsgTypeToDescription
// Author: M.A.Sargent  Date 31/05/18  Version: V1.0
//
// Notes:
// tMsgType = (mtInformation, mtWarning, mrError, mtException, mtCritical, tmHeartBeat);
//
Function fnDbValueToTypeMsg (Const aTypeMsg: String): tTypeMsg;
begin
  Try
    Result := IfValue (aTypeMsg, 'I', tmInformation,
                                 'W', tmWarning,
                                 'E', tmError,
                                 'X', tmException,
                                 'C', tmCritical,
                                 IfValue (aTypeMsg, 'H', tmHeartBeat,
                                                    'A', tmAdmin,
                                                    'V', tmVerbose, '999'));  // Should cause an exeption
  except
    Raise Exception.CreateFmt ('Error: fnDbValueToTypeMsg. Unknown values passed to routine (%s)',[aTypeMsg]);
  end;
end;
Function fnTypeMsgToDbValue (Const aTypeMsg: tTypeMsg): String;
begin
  Case aTypeMsg of
    tmInformation: Result := 'I';
    tmWarning:     Result := 'W';
    tmError:       Result := 'E';
    tmException:   Result := 'X';
    tmCritical:    Result := 'C';
    tmHeartBeat:   Result := 'H';
    tmAdmin:       Result := 'A';
    tmVerbose:     Result := 'V';
    else Raise Exception.CreateFmt ('Error: fnTypeMsgToDbValue. Unknown values passed to routine (%d)',[Ord (aTypeMsg)]);
  end;
end;
Function fnTypeMsgToDescription (Const aTypeMsg: tTypeMsg): String;
begin
  Case aTypeMsg of
    tmInformation: Result := 'Information';
    tmWarning:     Result := 'Warning';
    tmError:       Result := 'Error';
    tmException:   Result := 'eXception';
    tmCritical:    Result := 'Critical';
    tmHeartBeat:   Result := 'HeartBeat';
    tmAdmin:       Result := 'Admin';
    tmVerbose:     Result := 'Verbose';
    else Raise Exception.CreateFmt ('Error: fnTypeMsgToDescription. Unknown values passed to routine (%d)',[Ord (aTypeMsg)]);
  end;
end;

// Routine: fnPollingFileStatusToDbValue
// Author: M.A.Sargent  Date 13/06/18  Version: V1.0
//
// Notes:
// tPollingFileStatus = (pfsNew, pfsProcessed, pfsExcluded, pfsSuspect);
//
Function fnPollingFileStatusToDbValue (Const aValue: tPollingFileStatus): String;
begin
  Case aValue of
    pfsNew:       Result := cPOLLING_STATUS_NEW;
    pfsProcessed: Result := cPOLLING_STATUS_PROCESSED;
    pfsExcluded:  Result := cPOLLING_STATUS_EXCLUDED;
    pfsSuspect :  Result := cPOLLING_STATUS_SUSPECT;
    else Raise Exception.CreateFmt ('Error: fnPollingFileStatusToDbValue. Unknown values passed to routine (%d)',[Ord (aValue)]);
  end;
end;

// Routine: fnPollingFileStatusToDbValue
// Author: M.A.Sargent  Date 13/06/18  Version: V1.0
//
// Notes:
// tTSVerboseLevel = (tsvlNormal, tsvlFull, tsvlError, tsvlException);
//
Function fnVerboseLevelToInt (Const aValue: tTSVerboseLevel): Integer;
begin
  Result := Ord (aValue);
end;
Function fnVerboseLevelToStr (Const aValue: tTSVerboseLevel): String;
begin
  Result := IntToStr (fnVerboseLevelToInt (aValue));
end;
Function fnIntToVerboseLevel (Const aValue: Integer): tTSVerboseLevel;
begin
  Case aValue of
    cMC_ZERO:  Result := tsvlNormal;
    cMC_ONE:   Result := tsvlFull;
    cMC_TWO:   Result := tsvlError;
    cMC_THREE: Result := tsvlException;
    else Raise Exception.CreateFmt ('Error: fnIntToVerboseLevel. Unknown values passed to routine (%d)',[Ord (aValue)]);
  end;
end;
Function fnStrToVerboseLevel (Const aValue: String): tTSVerboseLevel;
begin
  Result := fnIntToVerboseLevel (StrToInt((aValue)));
end;
Function fnVerboseLevelToDescription (Const aValue: tTSVerboseLevel): String;
begin
  Case aValue of
    tsvlNormal:    Result := 'Normal';
    tsvlFull:      Result := 'Full';
    tsvlError:     Result := 'Error';
    tsvlException: Result := 'Exception';
    else Raise Exception.CreateFmt ('Error: fnVerboseLevelToDescription. Unknown values passed to routine (%d)',[Ord (aValue)]);
  end;
end;

// Routine: fnCmdToDesc
// Author: M.A.Sargent  Date 02/08/18  Version: V1.0
//
// Notes:
//
Function fnCmdToDesc (Const aCommand: Integer): String;
begin
  Case aCommand of
    cHWC_CMD_ABOUTINFO:      Result := 'Get About Info';
    cHWC_CMD_SETDATETIME:    Result := 'Set DateTime';
    //cHWC_CMD_SETPASSWORD:   Result := '';
    cHWC_CMD_GETTEMPLATE:    Result := 'Get Template';
    cHWC_CMD_SETTEMPLATE:    Result := 'Set Template';
    cHWC_CMD_TEST:           Result := 'Test Unit';
    cHWC_CMD_BACKUP_UNIT:    Result := 'Backup Users';
    cHWC_CMD_RESTORE_UNIT:   Result := 'Restore Users';
    cHWC_CMD_GETPARAMS:      Result := 'Get Parameters';
    cHWC_CMD_FEEDBACK:       Result := 'Feedback';
    cHWC_CMD_DOWNLOADDATA:   Result := 'Download Data';
    cHWC_CMD_RELOAD_UNITS:   Result := 'Reload Units Configuration';
    cHWC_CMD_STATUS:         Result := 'Status';
    cHWC_CMD_RESTART_UNITS:  Result := 'Restart Unit';
    cHWC_CMD_CLEAR_ADMIN:    Result := 'Clear Admin';
    else                     Result := fnTS_Format ('Unknown Command (%d', [aCommand]);
  end;
end;

// Routine: fnCmdToDesc
// Author: M.A.Sargent  Date 02/08/18  Version: V1.0
//
// Notes:
//
// 1 = Sick 2 = Holiday 3 = Paid Leave 4 = UnPaid Leave
// (Global Calendar only, are based by a factor of 10)
// 5 = Statutory 6 = Other 7 = Holiday 8 = Paid Leave 9
//
Function fnAbsenceTypeToInt (Const aValue: tAbsenceType): Integer;
begin
  Result := Ord (aValue);
end;
Function fnIntToAbsenceType (Const aValue: Integer): tAbsenceType;
begin
  Case aValue of
    cABSENCE_NONE:            Result := atNone;
    cABSENCE_SICK:            Result := atEmpSick;
    cABSENCE_HOLIDAY:         Result := atEmpHoliday;
    cABSENCE_PAIDLEAVE:       Result := atEmpPaidLeave;
    cABSENCE_UNPAIDLEAVE:     Result := atEmpUnPaidLeave;
    //
    cABSENCE_GBL_STATUTORY:   Result := atGlobalStatutory;
    cABSENCE_GBL_OTHER:       Result := atGlobalOther;
    cABSENCE_GBL_HOLIDAY:     Result := atGlobalHoliday;
    cABSENCE_GBL_PAIDLEAVE:   Result := atGlobalPaidLeave;
    cABSENCE_GBL_UNPAIDLEAVE: Result := atGlobalUnPaidLeave;
    else Raise Exception.CreateFmt ('Error: fnIntToAbsenceType. Unknow value passed to routine. (%d)', [aValue]);
  end;
end;

end.

//
// Unit: MAS_ConstsU
// Author: M.A.Sargent  Date: 20/01/17  Version: V1.0
//
// Notes:
//
unit MAS_ConstsU;

interface

Const
  cMC_NOT_FOUND           = -1;
  cMC_UNKNOWN             = -1;
  //
  cMC_ZERO_ROWS           = 0;
  cMC_ONE_ROW             = 1;
  cMC_FIRST_ROW           = 1;

  cMC_Y                   = 'Y';
  cMC_N                   = 'N';

  cMC_CR                  = #13;
  cMC_LF                  = #10;
  cMC_2CR                 = cMC_CR+cMC_CR;
  cMC_CRLF                = cMC_CR+cMC_LF;

  // Registry Stuff
  cMC_REG_DEFAULT         = '\Software';

  cMC_REG_CONFIG          = 'Config';
    //
    cMC_DONTASKAGAIN      = 'DontAskAgain';

  //
  cMC_WV_WINDOWS7         = 'Windows 7';
  cMC_WV_WINDOWS10        = 'Windows 10';

  // Number Consts
  cMC_ZERO                  = 0;
  cMC_1                     = 1;
  cMC_ONE                   = 1;
  cMC_2                     = 2;
  cMC_TWO                   = cMC_2;
  cMC_3                     = 3;
  cMC_THREE                 = cMC_3;
  cMC_4                     = 4;
  cMC_FIVE                  = 5;
  cMC_5                     = 5;
  cMC_10                    = 10;
  cMC_TEN                   = cMC_10;
  cMC_15                    = 15;
  cMC_20                    = 20;
  cMC_30                    = 30;
  cMC_50                    = 50;
  cMC_60                    = 60;
  cMC_100                   = 100;
  cMC_250                   = 250;
  cMC_500                   = 500;
  cMC_600                   = 600;
  cMC_1000                  = 1000;
  cMC_1500                  = 1500;
  cMC_1800                  = 1800;
  //
  cMC_ONE_SECOND            = 1;
  cMC_5_SECONDS             = 5;
  cMC_10_SECONDS            = 10;
  cMC_15_SECONDS            = 15;
  cMC_30_SECONDS            = 30;
  cMC_60_SECONDS            = 60;
  //
  cMC_MINUTE_IN_SECONDS     = 60;
  cMC_2_MINUTES_IN_SECONDS  = 120;
  cMC_3_MINUTES_IN_SECONDS  = 180;
  cMC_4_MINUTES_IN_SECONDS  = 240;
  cMC_5_MINUTES_IN_SECONDS  = 300;
  cMC_10_MINUTES_IN_SECONDS = 600;
  cMC_15_MINUTES_IN_SECONDS = 900;
  cMC_30_MINUTES_IN_SECONDS = 1800;
  cMC_HOUR_IN_SECONDS       = 3600;
  cMC_DAY_IN_SECONDS        = 86400;

  // Milli Second Constants
  cMC_50Ms                  = 50;
  cMC_100Ms                 = 100;
  cMC_200Ms                 = 200;
  cMC_250Ms                 = 250;
  cMC_500Ms                 = 500;
  cMC_740Ms                 = 750;
  cMC_1000Ms                = 1000;
  cMC_2000Ms                = 2000;
  cMC_3000Ms                = 3000;
  cMC_5000Ms                = 5000;
  cMC_3_SECONDS_Ms          = 3000;
  cMC_5_SECONDS_Ms          = 5000;
  cMC_10_SECONDS_Ms         = 10000;
  cMC_15_SECONDS_Ms         = 15000;
  cMC_20_SECONDS_Ms         = 20000;
  cMC_30_SECONDS_Ms         = 30000;
  cMC_60_SECONDS_Ms         = 60000;

  // Maths constants
  cMAX_CARDINAL             = 4294967295;

  // Output Directories
  cDIR_COMMON_LOGFILES    = 'Common\LogFiles';

  // FileName and Extensions
  cFILE_EXTN_INI          = '.Ini';
  cFILE_EXTN_TXT          = '.Txt';


  cWIN_VER_2000            = 'Windows 2000';
  cWIN_VER_XP              = 'Windows XP';
  cWIN_VER_SERVER_2003     = 'Windows Server 2003';
  cWIN_VER_SERVER_2003_R2  = 'Windows Server 2003 R2';
  cWIN_VER_SERVER_VISTA    = 'Windows Vista';
  cWIN_VER_SERVER_2008     = 'Windows Server 2008';
  cWIN_VER_SERVER_2008_R2  = 'Windows Server 2008 R2';
  cWIN_VER_7               = 'Windows 7';
  cWIN_VER_UNKNOWN         = 'Unknown';

  //
  cDATETIME_NON_NOT_LOCALISED     = 'YYYYMMDD_HHNN';
  cDATETIME_NON_NOT_LOCALISED_SS  = 'YYYYMMDD_HHNNSS';

   //
   // New Common Messages
   //
   cmsg_CONFIRM_LOSS_CHANGES          = 'Changes have been made, Do you want to continue and loss the changes you have made?';


implementation

end.



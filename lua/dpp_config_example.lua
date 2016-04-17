
--Define the array
DPP_MySQLConfig = {}

--THIS IS AN EXAMPLE FILE
--IT DOES NOT LOADED BY DPP
--TO MAKE ANY CHANGES, RENAME THIS FILE TO dpp_config.lua

--[[
This is DPP MySQL config
It will be loaded before DPP initializes it's MySQL Connection
In order to use MySQL, your server should have TMySQL4 installed
(or use MySQLoo what is not working good)

You can get TMySQL4 here:
https://facepunch.com/showthread.php?t=1442438

Last known working verions:
Linux: https://github.com/blackawps/gm_tmysql4/releases/download/R1.01/gmsv_tmysql4_linux.dll
Windows: https://github.com/blackawps/gm_tmysql4/releases/download/R1/gmsv_tmysql4_win32.dll
]]

--Should we use MySQL?
DPP_MySQLConfig.UseMySQL = true

--If so, what is username?
DPP_MySQLConfig.Username = 'dpp'

--Password?
DPP_MySQLConfig.Password = ''

--Database? 
DPP_MySQLConfig.Database = 'dpp'

--Usually it is localhost
DPP_MySQLConfig.Host = 'localhost'

--MySQL port. Usually it is 3306
DPP_MySQLConfig.Port = 3306
@REM https://superuser.com/questions/204909/cant-delete-folder-and-i-am-admin-you-need-permission-to-perform-this-action
@REM Right click on the file “delete.bat” select “Run As Administrator” and you should now have full control of the directory and all sub directories meaning you can do what you wish with them.
SET DIRECTORY_NAME="D:\Win11VM\Win\paging\Virtual Machines"
TAKEOWN /f %DIRECTORY_NAME% /r /d y
ICACLS %DIRECTORY_NAME% /grant administrators:F /t
ICACLS %DIRECTORY_NAME% /reset /T
PAUSE
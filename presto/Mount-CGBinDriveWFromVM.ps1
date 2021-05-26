using namespace System.Management.Automation

$user = 'metaseed'
$password = ConvertTo-SecureString -string '0' -AsPlainText -Force

$credential = New-Object -TypeName PSCredential  -ArgumentList $user, $password

New-PSDrive -Name W -PSProvider FileSystem -Root \\172.17.57.24\bin -Credential $credential -Persist -Scope Global
# if error:  Multiple connections to a server or shared resource by the same user, using more than one user name, are not allowed. Disconnect all previous connections to the server or shared resource and try again
# try 
# net use 
# net use /delete  \\172.17.57.24\IPC$
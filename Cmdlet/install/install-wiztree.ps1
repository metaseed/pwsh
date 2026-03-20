# note : not work, find a earlier version
# href="files/wiztree_4_25_portable.zip"
Install-FromWeb 'https://diskanalyzer.com/download'  '<a .*href="(files\/wiztree_4_25_portable\.zip)".*>.*DOWNLOAD PORTABLE' -newName wiztree @args

ni -Type HardLink M:\app\wiztree\size.exe -Value M:\app\wiztree\WizTree64.exe


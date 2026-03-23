
ipmo Metaseed.Management -Force
Install-FromGithub https://github.com/oschwartz10612/poppler-windows '\.zip$' -versionType 'preview' @args

Add-PathEnv 'C:\App\poppler-windows\Library\bin'
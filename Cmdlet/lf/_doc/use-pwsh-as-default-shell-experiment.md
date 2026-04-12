> my main script is ps1, every time to invoke a command we need to launch a new pwsh process to execute the script which is slow

https://github.com/gokcehan/lf/pull/768

the benefit: https://github.com/gokcehan/lf/wiki/Troubleshoot#multiline-shell-commands-dont-work-on-windows

actually everytime it invoke a command directly with a new shell instance of pwsh, so not good than directly using cmd:
we can test this via: gps pwsh
i.e. before `af` and after `af`
@echo off
@REM (1) current file name, (2) width, (3) height, (4) horizontal position, and (5) vertical position of preview pane
@REM SIGPIPE signal is sent when enough lines are read. If the previewer returns a non-zero exit code,
@REM then the preview cache for the given file is disabled. This means that if the file is selected in the future,
@REM the previewer is called once again. Preview filtering is disabled and files are displayed as they are when the value of this option is left empty.
@REM python M:/Script/Pwsh/Cmdlet/lf/config/scripts/lf_preview.py %0 %1 %2 %3 %4 %5 %6 %7 %8

@REM https://github.com/gokcehan/lf/issues/234
@REM set COLORTERM=
@REM bat --color=always --theme=base16 $Args[0]

set item=%1
@REM IF not x%item:.md=%==x%item% (
@REM 	glow %1 -s dark
@REM ) ELSE IF not x%item:.7z=%==x%item% (
@REM 	7z l %1 | bat
@REM ) ELSE IF not x%item:.zip=%==x%item% (
@REM 	unzip -l %1 | bat
@REM ) ELSE IF not x%item:.rar=%==x%item% (
@REM 	unrar l %1 | bat
@REM ) ELSE (
	bat --color=always --theme=base16 %1
@REM )

how to generate a shim exe
# chocolate
in folder: C:\ProgramData\chocolatey\tools

description: https://docs.chocolatey.org/en-us/features/shim/

we copied it to the app folder.
> to see more help:
> `shimgen -h`
>
try it with
`shimgen -p="./7z.exe" -o="m:\app\_shim\7z.exe"`
it generated a shim, but not work

> so we remove the shimgen.exe from App folder
>
#
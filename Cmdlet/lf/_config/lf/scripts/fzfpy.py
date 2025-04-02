import os
import sys
import subprocess

if __name__ == '__main__':
    output = subprocess.run(['M:\\Script\\pwsh\\Cmdlet\\lf\\config\\scripts\\findfzf.bat'], capture_output=True)
    selected = output.stdout.decode('utf8').split('\n')[-2].strip('\\')

    command = 'cd'
    if not os.path.isdir(selected):
        command = 'select'

    pwd = os.environ.get('PWD').strip('"')
    # check if path is a file
    selectedPath = fr'"{pwd}\{selected}"'
    # print(selectedPath)
    id=sys.argv[1]
    cmd = fr'send {id} {command} {selectedPath}'.replace('\\','/')
    print(cmd)
    subprocess.run(['lf', '-remote', cmd])

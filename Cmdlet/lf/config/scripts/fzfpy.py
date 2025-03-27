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
    selectedPath = f"\"{pwd}\\{selected}\""
    # print(selectedPath)
    subprocess.run(['lf', '-remote', 'send {id} {command} {selectedPath}'.format(id=sys.argv[1], selected=selected, command=command, selectedPath=selectedPath)])


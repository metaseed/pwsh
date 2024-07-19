[Document](https://github.com/gokcehan/lf/blob/master/doc.md)

> with powershell, we can not pass argument parameters
## tips
glob: ? * [] [^]:  '*' matches any sequence, '?' matches any character, and '[...]' or '[^...] matches character sets or ranges.
if a pattern starts with '!', then its matches are excluded from hidden files.

* $env:f : file/folder at cursor
* $env:fx : files/folders selected or file/folder at cursor if no selection

### commands
right : open the item

### bookmarks
> quickly navigate between dirs.

m  : save a key as a mark for the current dir. `ma`
'  : change dir to the key mark. 'a
"  : remove the mark "a
### navigation
cd : change working directory, i.e. `:cd 'c:\temp'`. note: the path need to be a single quoted string
gh: go to home directory
f: find char in file names, ;: next; ,: previous
/: searching; n:next; N: previous i.e. `/tex<enter>` find 'tex' in file names
?: search back
c-u : half-page up
c-n : half-page down
c-e : scroll up
c-d : scroll down
H: high
M: middle
L: low

### file management
y: copy
rr or rn: rename
d : cut
c : clear selection or cutting
p : paste
<space>: toggle selection
su: unselect all
si: invert all selection

<delete>: trash to recycle bin
D : delete permanently
af : add new file
ad : add new directory

### Display
c-l : redraw (refresh)
c-r : flush cache and reload modified files and directories

ctime: changing time: ownership, permissions
mtime: modification time. content
atime: access time. open

sa: sort by access time
st: sort by modification time
sc: sort by changing time

za: show size and time info
zt: show time info
zs: show size info
zn: no info
zh: toggle hidden
zr: reverse current sorting

shell          (modal)   (default '$')
shell-pipe     (modal)   (default '%')
shell-wait     (modal)   (default '!')
shell-async    (modal)   (default '&')
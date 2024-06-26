[Document](https://github.com/gokcehan/lf/blob/master/doc.md)

> with powershell, we can not pass argument parameters
## tips
glob: ? * [] [^]:  '*' matches any sequence, '?' matches any character, and '[...]' or '[^...] matches character sets or ranges.
if a pattern starts with '!', then its matches are excluded from hidden files.
### commands
right : open the item

### bookmarks
m  : save a key as a mark for the current dir. ma
'  : change dir to the key mark. 'a
"  : remove the mark "a
### navigation
cd : change working directory, i.e. cd: 'c:\temp'. note: the path need to be a single quoted string
gh: go to home directory
f: first char in the directory, ;: next; ,: previous
/: searching; n:next; N: previous
?: search back
c-u : half-page up
c-d : half-page down
M: middle

### file management
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

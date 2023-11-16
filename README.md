# Link_Opener
(Currently available for Linux)

* A CLI tool for `Power Users` to smartly open websites.
* **Just type the shortcut in terminal and it will open your favourite site in browser.**
* User can save frequently visited sites with shortcuts.
* Then just use the shortcuts to open the sites in the default browser.

## How to compile and run
```
v run .
```
## How to use
1. Download the zip file from [here](https://github.com/giridhrubajyoti2002/link_opener/blob/master/link_opener-linux.tar.xz).
2. Unzip and place the folder in a place.
3. Add the `lo` file path to $PATH or $SYSTEM_VARIABLES
4. Now you can use the bellow commands to smartly manage your frequently visited sites.

## Commands
* `ls` is a reserved keyword, use it to see all the saved links.
* Other reserved keywords are `q, quit, exit, help`
### add a link
```
lo -a leetcode.com -s lc
```
### open a link
```
lo -o lc
```
### move a link (change its position)
```
lo -m lc -p 2
```
### remove a link
```
lo -r lc
```
### use prompt
```
lo
```
```
Type `help` for more information.
>>> ls
<position>              <shortcut>               <url>           <time_added>
1               lc      https://leetcode.com    2023-11-13 18:00:31
2               gfg     https://geeksforgeeks.org       2023-11-13 17:32:51
>>> lc
`https://leetcode.com` opened in default browser.
>>> 2
`https://geeksforgeeks.org` opened in default browser.
>>> q
```



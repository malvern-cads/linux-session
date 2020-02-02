# CADS Linux Cheatsheet

## Basic Commands
### `cd`
- Stands for change directory. Can be used to navigate around the shell
- e.g. `cd instructions` will move your location into the instructions folder
- `cd ..` can be use to move up a directory
- `cd ~` or just `cd` can be used to jump back to your home directory
### `ls`
- Stands for list. Can be use to show what files and folders are in your current directory
- e.g.
  ```
  user@CADS ~ $ ls
  research instructions animals
  ```
- `ls -l` shows more detailed information of the files, including the permissions and who owns the file
- `ls -a` shows all files, including the current one (`.`), the above one (`..`) and hidden ones (ones that start with `.` e.g. `.secret.txt`)
### `pwd`
- Stands for print working directory. It will show you your current location within the file system.
### `cat`
- Stands for concatenate. Can be used to join text files and print the output.
- For these tasks we'll use it to only print out a file to the screen
- e.g.
  ```
  user@CADS instructions $ cat level1.txt
  whatever is in level1.txt
  ...
  ```
### `nano`
- nano is a terminal based text editor. It will be used to edit the files of today's challenges.
- usage `nano filename.txt`
- Once in nano you can move around as if it was notepad on windows. To close it press ctrl-x, press y if you want to save the file.
### `mkdir`
- Stands for make directory. Can be use to create new folders.
- e.g. 
  ```
  user@CADS ~ $ mkdir homework
  user@CADS ~ $ ls
  research instructions animals
  ```
### `cp`
- Stands for copy. Can be used to copy files and folders.
- Usage `cp <file to copy> <destination of file>`
- e.g. if you wanted to copy `cow.txt` to `sheep.txt`
  ```
  user@CADS animals $ cp cow.txt sheep.txt
  user@CADS animals $ ls
  cow.txt sheep.txt whale.txt
  ```
- If you want to copy directories you must use `cp -r`
### `mv`
- Stands for move. Can be used for moving files and renaming files.
- Usage `mv <file to move> <destination of file>`
- e.g. if you wanted to rename whale.txt to fish.txt
  ```
  user@CADS animals $ mv whale.txt fish.txt
  user@CADS animals $ ls
  cow.txt fish.txt
  ```
   



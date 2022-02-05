Hardcore °Bx [![Version](/util/version.png)] [minetest_hardcorebrix] 
=====================

Mod for minetest that adds some hardcore bricks and durable building materials to the game. Say goodbye to swiss-cheese map with giant holes, these new blocks are hard to dig and can be a real help for house protection. It's hardcore time!

![Hardcore °Bx](/minetest_hardcorebrix_info.png?raw=true "Hardcore Brix mod info")

**How to download**

https://github.com/aa6/minetest_hardcorebrix/archive/master.zip

**How to install**

http://wiki.minetest.com/wiki/Installing_mods

**Development**

- Run `git clone https://github.com/aa6/minetest_hardcorebrix.git; cd minetest_hardcorebrix` to clone the repository.
- Run `bash util/git_hook_pre_commit.bash install` after repository cloning. `./VERSION` and `./util/version.png` then will be updated automatically on every commit. To increment minor version append " 2" to `./VERSION` file contents.
- Use `print(dump( ... ))` to print tables to console when debugging.
- Use `error(123)` to stop execution when debugging.
- Remember that array numeration in Lua starts not from `0` but from `1`: `arr = { 123 }; -- arr[0] == nil; arr[1] == 123`.
- Use manual http://dev.minetest.net/Category:Methods

**Changelog**

https://github.com/aa6/minetest_hardcorebrix/commits/master

**Links**

[Minetest forums topic](https://forum.minetest.net/viewtopic.php?f=11&t=9673)
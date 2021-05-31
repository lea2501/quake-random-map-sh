# quake-random-map-sh

This is a random quake map launcher script i made for myself, tired of having to remember which maps i already played and what progress i made in them, and enjoying to make temporary slige maps to play and enjoy, i came with this idea to have a script, that get a random map to play, either be them PAK files or bsp maps in the quake subdirectories.

If the file is a PAK file, it searches its contents for maps using the qpakman tool https://github.com/bunder/qpakman

It launches the random map using quakespasm installed system wide already in your PATH, but you can change the script to run with any source port, i choosed quakespasm because it can play any existing map always.

Dependencies:
```
quakespasm: https://quakespasm.sourceforge.net/
qpakman: https://github.com/bunder/qpakman
```

Usage:
```
$ ./quake-random-map.sh -h
Usage: ./quake-random-map.sh [options [parameters]]

Options:
 -g|--game-dir   [/path/to/quake/base/directory] (Optional, default: '~/games/quake')
 -d|--mod-dir    [id1|ad|jam9|quoth|hipnotic|...] (Optional, default: '*' (all subdirectories))
 -u|--mangohud   [yes|no]
 -h|--help, Print help
```
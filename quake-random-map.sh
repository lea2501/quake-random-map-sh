#!/bin/sh

### Configuration
QUAKE_DIR=~/games/quake

if [ -z "$1" ]
then
      QUAKE_SUB_DIR=*
else
      QUAKE_SUB_DIR=$1
fi

### Script
get_map_file() {
    mapfile=$(find $QUAKE_DIR/$QUAKE_SUB_DIR/{maps/*.bsp,pak0.pak} -type f | shuf -n 1)

    if [[ $mapfile == *"pak"* ]]; then
        pakfile=$mapfile
        mapfile=$(qpakman -l $pakfile | grep 'maps/' | grep '.bsp' | awk '{ print $5 }' | shuf -n 1)
    fi
}

###
# Quake random map script
###
get_map_file

while [[ -z $mapfile || $mapfile == *"/b_"* || $mapfile == *"_obj_"* || $mapfile == *"_brk"* || $mapfile == *"/m_"* || $mapfile == *"bmodels"* ]]
do
    echo "Incorrect map" $mapfile "getting another map..."
    unset pakfile
    unset mapfile
    get_map_file
done

# Get game name
if [[ ! -z $pakfile ]]; then
    gamename=$(awk -F/ '{print $6}' <<< "${pakfile}")
else
    gamename=$(awk -F/ '{print $6}' <<< "${mapfile}")
fi
echo $gamename

# get map name
if [[ ! -z $pakfile ]]; then
    mapname=$(basename -- "${mapfile%.*}")
else
    mapname=$(basename -- "${mapfile%.*}")
fi
echo $mapname

# Run Quake
quakespasm -width 1920 -height 1080 -fullscreen -basedir $QUAKE_DIR -heapsize 256000 -zone 4096 -game $gamename +map $mapname +skill 1 +exec $QUAKE_DIR/id1/autoexec.cfg -fitz

# Print map name and pak file
if [[ ! -z $pakfile ]]; then
    echo $pakfile
fi
echo $mapfile
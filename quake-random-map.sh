#!/bin/sh

get_map_file() {
    mapfile=$(find ~/games/quake/*/{maps/*.bsp,pak0.pak} -type f | shuf -n 1)

    if [[ $mapfile == *"pak"* ]]; then
        pakfile=$mapfile
        mapfile=$(qpakman -l $pakfile | grep 'maps/' | grep '.bsp' | awk '{ print $5 }' | shuf -n 1)
    fi
}

###
# Quake random map script
###
get_map_file

while [[ $mapfile == *"/b_"* || $mapfile == *"_obj_"* || $mapfile == *"_brk"* || $mapfile == *"/m_"* || $mapfile == *"bmodels"* ]]
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
quakespasm -width 1920 -height 1080 -fullscreen -basedir ~/games/quake/ -heapsize 256000 -zone 4096 -game $gamename +map $mapname +skill 1 +exec ~/games/quake/id1/autoexec.cfg -fitz

# Print map name and pak file
if [[ ! -z $pakfile ]]; then
    echo $pakfile
fi
echo $mapfile
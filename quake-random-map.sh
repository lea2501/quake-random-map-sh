#!/bin/sh

# exit when any command fails
set -e
# debug log
#set -x

function show_usage (){
    printf "Usage: $0 [options [parameters]]\n"
    printf "\n"
    printf "Options:\n"
    printf " -g|--game-dir   [/path/to/quake/base/directory] (Optional, default: '~/games/quake')\n"
    printf " -d|--mod-dir    [id1|ad|jam9|quoth|hipnotic|...] (Optional, default: '*' (all subdirectories))\n"
    printf " -u|--mangohud   [yes|no] (Optional, default: 'no'\n"
    printf " -h|--help, Print help\n"

exit
}

if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]];then
    show_usage
fi

while [ ! -z "$1" ]; do
  case "$1" in
     --game-dir|-g)
         shift
         echo "mod directory: $1"
         QUAKE_SUB_DIR=$1
         ;;
     --mod-dir|-d)
         shift
         echo "mod directory: $1"
         QUAKE_SUB_DIR=$1
         ;;
     --mangohud|-u)
        shift
        echo "mangohud: $1"
        MANGOHUD_ENABLED=$1
         ;;
     *)
        show_usage
        ;;
  esac
shift
done

### Configuration
if [[ -z $QUAKE_DIR ]]; then
      QUAKE_DIR=~/games/quake
fi
SCRIPT_DIR="$(pwd $(dirname $0))"
if [[ -z $QUAKE_SUB_DIR ]]; then
      QUAKE_SUB_DIR=*
fi
if [[ -z $MANGOHUD_ENABLED ]]; then
      MANGOHUD_ENABLED=no
fi
mapdir=
scriptdir="$(pwd $(dirname $0))"

### check parameter values
mangohud_enabled=(yes no)
if [[ " "${mangohud_enabled[@]}" " != *" $MANGOHUD_ENABLED "* ]]; then
    echo "$MANGOHUD_ENABLED: not recognized. Valid mangohud options are:"
    echo "${mangohud_enabled[@]/%/,}"
    exit 1
fi


### Script
get_map_file() {
    mapfile=$(find $QUAKE_DIR/$QUAKE_SUB_DIR/{maps/*.bsp,pak0.pak} -type f | shuf -n 1)

    if [[ $mapfile == *"pak"* ]]; then
        # Get map directory name
        mapdir="$(dirname "$mapfile")"
        mapdir="$(awk -F/ '{print $(NF)}' <<< "${mapdir}")"
        # Get map pak file map name
        pakfile=$mapfile
        mapfile=$(qpakman -l $pakfile | grep 'maps/' | grep '.bsp' | awk '{ print $5 }' | shuf -n 1)
    else
        # Get map directory name
        mapdir="$(dirname "$mapfile")"
        mapdir="$(awk -F/ '{print $(NF-1)}' <<< "${mapdir}")"
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

# Save map info in external file
if [[ ! -z $pakfile ]]; then
    play_combination="${pakfile},${mapdir},${mapfile}"
else
    play_combination="${mapdir},${mapfile}"
fi
play_combination=$(sed 's/ /_/g' <<< "${play_combination}")

# Check played times in external file
if [ ! -z $(grep "${play_combination}" ${SCRIPT_DIR}/already_played_maps.txt) ]; then 
    echo "Play combination found in file, updating file"
    current_times=$(cat ${SCRIPT_DIR}/already_played_maps.txt | grep ${play_combination} | awk -F, '{print $4}')
    played_times=$(echo "$(($current_times + 1))")

    # Update file
    sed -i "s|${play_combination},${current_times}|${play_combination},${played_times}|g" ${SCRIPT_DIR}/already_played_maps.txt
else
    echo "Play combination not found in file, adding to file"
    played_times="1"
    new_played="${play_combination},${played_times}"
    echo "${new_played}" >> ${SCRIPT_DIR}/already_played_maps.txt
fi

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

if [[ $MANGOHUD_ENABLED == "yes" ]]; then
    export MANGOHUD_DLSYM=1
    #export MANGOHUD_CONFIG=cpu_temp,gpu_temp,core_load,cpu_core_clock,gpu_mem_clock,cpu_power,gpu_power,cpu_mhz,ram,vram,frametime,position=top-left,height=500,font_size=24
    export MANGOHUD_CONFIG=cpu_temp,gpu_temp,cpu_core_clock,gpu_mem_clock,cpu_power,gpu_power,cpu_mhz,ram,vram,frametime,position=top-left,height=500,font_size=18
fi

# Run
commandline="quakespasm -current -basedir $QUAKE_DIR -heapsize 524288 -zone 4096 -game $gamename +map $mapname +skill 1 -fitz"
if [[ $MANGOHUD_ENABLED == "yes" ]]; then
    mangohud $commandline || true
else
    $commandline || true
fi

# Print map name and pak file
if [[ ! -z $pakfile ]]; then
    echo "PAK file            : $pakfile"
fi
echo "MAP file            : $mapfile"
echo "Full command line   : $commandline"
echo ""
echo "map: ${play_combination}"
echo "map played ${played_times} times"

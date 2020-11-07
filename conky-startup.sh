#!/bin/bash

DC=#000000
C1=#68A1DF
C2=00ff00
C3=#FBFFFE

default_theme() {
    DC=#000000
    C1=#68A1DF
    C2=00ff00
    C3=#FBFFFE
}

rog_theme() {
    DC=#000000
    C1=#68A1DF
    C2=ff0000
    C3=#FBFFFE
}

cpu_list() {
    processor_count=$(expr $(cat /proc/cpuinfo | grep processor | wc -l) - 1)
    for CPUID1 in $(seq 0 $processor_count)
    do
        if [[ $(expr $CPUID1 % 2) == 0 ]]; then
            CPUID2=$(expr $CPUID1 + 1)
            CPU_LINE="\${voffset 2}\${color1}$(printf "%02d" $(expr $CPUID1 + 1))  \${color3}\${cpu cpu$CPUID1}%\${goto 150}\${color2}\${cpubar cpu$CPUID1 24, 180}\${goto 360}\${color1}$(printf "%02d" $(expr $CPUID2 + 1))  \${color3}\${cpu cpu$CPUID2}%  \${color2}\${alignr}\${cpubar cpu$CPUID2 24, 180}"
            echo $CPU_LINE
        fi
    done
}

mount_list() {
	for MNT in $(df -h |grep -v -E 'loop|udev|tmpfs|boot' | sed -n '1!p' | cut -d '%' -f 2| tr -d ' ' | sort)
	do
		if [[ $MNT == "/" ]]; then
			NAME="root"
		else
			NAME=$(echo $MNT | rev | cut -d '/' -f1 | rev)
		fi
		echo "\${voffset 10}\${color1}${NAME^} \${goto 120}\${color2}\${fs_bar 20 ${MNT}}"
		echo "\${goto 120}\${color1}Used: \${color3}\${fs_used ${MNT}}\${color1}\${alignr}Free: \${color3}\${fs_free ${MNT}}"
	done
}

# Set the theme
rog_theme

# Run conky on all displays
DISPLAY_TOTAL=$(expr $(xrandr | grep " connected" | wc -l) - 1)
for display in $(seq 0 $DISPLAY_TOTAL)
do
    cat << EOF | conky -c -
--[[
#=================================================
# Author  : Zvonimir Kucis
#=================================================
]]

conky.config = {

	--Various settings

	background = true,
	cpu_avg_samples = 2,
	diskio_avg_samples = 10,
	double_buffer = true,
	if_up_strictness = 'address',
	net_avg_samples = 2,
	no_buffers = true,
	temperature_unit = 'celsius',
	update_interval = 1,
	imlib_cache_size = 0,

	--Placement

    alignment = 'top_right',
    xinerama_head = ${display},
	gap_x = 10,
	gap_y = 45,
	minimum_height = 1300,
	minimum_width = 600,
	maximum_width = 600,

	--Graphical

	border_inner_margin = 20,
	border_outer_margin = 20,
	draw_borders = false,
	draw_graph_borders = true,
	draw_shades = false,
	draw_outline = false,

	--Textual
	
	format_human_readable = true,
	font = 'ubuntu:size=10:bold',
	max_text_width = 0,
	short_units = true,
	use_xft = true,
	xftalpha = 1,

	--Windows

	own_window = true,
    own_window_class = 'Conky',
    own_window_type = 'normal',
    own_window_hints = 'undecorated,below,skip_taskbar,sticky,skip_pager',

	own_window_argb_value = 0,
	own_window_argb_visual = true,
	

	--Colours

	default_color = '$DC',  				-- default color and border color
	color1 = '$C1', 					-- title_color
        color2 = '$C2',
	color3 = '$C3',				        -- text color
};


conky.text = [[
#------------+
# INFO
#------------+
\${color1}\${font :size=14:bold}INFO \${hr 2}\${font}
\${voffset 10}\${color1}OS :\$alignr\${color3}\${execi 6000 lsb_release -d | grep 'Descr'|awk {'print \$2 " " \$3" " \$4" " \$5'}}
\${voffset 2}\${color1}Kernel :\$alignr\${color3} \$kernel
\${voffset 2}\${color1}Uptime :\$alignr\${color3} \$uptime
#------------+
#CPU
#------------+
\${voffset 10}\${color1}\${font :size=14:bold}CPU \${hr 2}\${font}
\${voffset 10}\${color1}Name : \${color3}\$alignr\${execi 6000 cat /proc/cpuinfo | grep 'model name' | sed -e 's/model name.*: //'| uniq | sed -e 's/(R)//' | sed -e 's/(TM)//' | sed -e 's/CPU//'}
\${voffset 2}\${color1}Freq : \${color3}\${freq_g} GHz\$alignr\${color1}Usage : \${color3}\${cpu}%
#------------+
#CPU CORES
#------------+
\${voffset 10}\${color1}CPU CORES \${stippled_hr 3 3}
$(cpu_list)
#------------+
#TEMPS
#------------+
\${voffset 10}\${color1}\${font :size=14:bold}TEMPS \${hr 2}\${font}
\${voffset 10}\${color1}CPU:  \${color3}\${execi 5 sensors | grep Package | cut -c 17-20}°C\${goto 300}\${color1}GPU:  \${color3}\${nvidia temp}°C\${alignr}\${color1}NVME:  \${color3}\${execi 5 sudo smartctl -A /dev/nvme0 | awk 'FNR==7 {print \$2}' }°C
#------------+
# PROCESSES
#------------+
\${voffset 10}\${color1}\${font :size=14:bold}PROCESSES \${hr 2}\${font}
\${voffset 10}\${color1}Name\${goto 360}CPU%\${alignr}MEM%
\${color2}\${top name 1} \${goto 360}\${top cpu 1}\${alignr}\${top mem 1}\${color3}
\${top name 2} \${goto 360}\${top cpu 2}\${alignr}\${top mem 2}
\${top name 3} \${goto 360}\${top cpu 3}\${alignr}\${top mem 3}
\${top name 4} \${goto 360}\${top cpu 4}\${alignr}\${top mem 4}
\${top name 5} \${goto 360}\${top cpu 5}\${alignr}\${top mem 5}
#------------+
# MEMORY
#------------+
\${voffset 10}\${color1}\${font :size=14:bold}MEMORY \${hr 2}\${font}
\${voffset 10}\${color1}Total: \${color3}\${execi 6000 printf "%.1f GB\n" "\$((\$(cat /proc/meminfo | grep MemTotal | cut -d ":" -f 2 | tr -d ' ' | cut -d 'k' -f 1) / 1024 / 1024 ))"}
\${voffset 10}\${color2}\${membar 20 /}
\${voffset 5}\${color1}Used: \${color3}\$mem (\$memperc%)\${color1}\${alignr}Free: \${color3}\$memeasyfree
\${color1}\${stippled_hr 10 1}
\${voffset 10}\${color1}Name\${goto 360}MEM%\${alignr}MEM
\${color2}\${top_mem name 1} \${goto 360}\${top_mem mem 1}\${alignr}\${top_mem mem_res 1}\${color3}
\${top_mem name 2} \${goto 360}\${top_mem mem 2}\${alignr}\${top_mem mem_res 2}
\${top_mem name 3} \${goto 360}\${top_mem mem 3}\${alignr}\${top_mem mem_res 3}
\${top_mem name 4} \${goto 360}\${top_mem mem 4}\${alignr}\${top_mem mem_res 4}
\${top_mem name 5} \${goto 360}\${top_mem mem 5}\${alignr}\${top_mem mem_res 5}
#------------+
# GPU
#------------+
\${voffset 10}\${color1}\${font :size=14:bold}VIDEO \${hr 2}\${font}
\${voffset 10}\${color1}GPU :\$alignr\${color3}\${execi 6000 nvidia-smi --query-gpu=gpu_name --format=csv,noheader,nounits | cut -d 'w' -f 1}
\${color1}Driver :\$alignr\${color3}\${execi 6000 nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits}
\${color1}Utilization :\$alignr\${color3}\${exec nvidia-smi -i 0 | grep % | cut -c 61-63} %
\${color1}VRAM Utilization :\$alignr\${color3}\${exec nvidia-smi -i 0| grep % | cut -c 37-40} MB
#------------+
# DISK
#------------+
\${voffset 10}\${color1}\${font :size=14:bold}DISK \${hr 2}\${font}
# NVME
#\${voffset 10}\${color1}NVME \${stippled_hr 3 3}
$(mount_list)
\${voffset 20}\${color1}Read: \${color3}\${diskio_read nvme0n1}\${goto 340}\${color1}Write: \${color3}\${diskio_write nvme0n1}
\${color2}\${diskiograph_read nvme0n1 40,270} \${alignr}\${diskiograph_write nvme0n1 40,270}
#------------+
# NETWORK
#------------+
\${voffset 10}\${color1}\${font :size=14:bold}NETWORK \${hr 2}\${font}
\${voffset 10}\${color3}Up: \${upspeedf wlo1} KiB/s\${alignr}Down: \${downspeedf wlo1} KiB/s
\${color2}\${upspeedgraph wlo1 40,270 l}\$alignr\${downspeedgraph wlo1 40, 270 -l}
#------------+
]]
EOF
done


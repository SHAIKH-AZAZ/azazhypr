#!/bin/sh
# One-shot system sample, key=value per line. Called every 2s by services/Sys.qml.
awk 'NR>2&&$1!="lo:"{r+=$2;t+=$10}END{printf "net=%d %d\n",r,t}' /proc/net/dev
awk 'NR==1{printf "cpu=%d %d\n",$2+$3+$4+$5+$6+$7+$8,$5+$6}' /proc/stat
awk '/^MemTotal/{t=$2}/^MemAvailable/{a=$2}END{printf "ram=%d\n",(t-a)*100/t}' /proc/meminfo
echo "disk=$(df --output=pcent / | tail -1 | tr -dc 0-9)"
t=""
for z in /sys/class/thermal/thermal_zone*; do
  [ "$(cat "$z/type" 2>/dev/null)" = x86_pkg_temp ] && t=$(cat "$z/temp") && break
done
[ -z "$t" ] && t=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
echo "temp=$t"
echo "bright=$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d %)"
echo "rec=$(pgrep -x wf-recorder >/dev/null && echo 1 || echo 0)"
echo "sunset=$(pgrep -x hyprsunset >/dev/null && echo 1 || echo 0)"
echo "wifiradio=$(nmcli radio wifi 2>/dev/null)"
echo "airplane=$(rfkill -n -o SOFT list 2>/dev/null | grep -q unblocked && echo 0 || echo 1)"
echo "kb=$(hyprctl devices -j 2>/dev/null | jq -r '(([.keyboards[]|select(.main)][0]) // .keyboards[0]) | "\(.active_keymap)|\(.layout)"' 2>/dev/null)"
echo "pacman=$(stat -c %Y /var/lib/pacman/local 2>/dev/null)"
echo "ssid=$(nmcli -t -f NAME,TYPE con show --active 2>/dev/null | sed -n 's/:802-11-wireless$//p' | head -1)"

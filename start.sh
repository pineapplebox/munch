#!/bin/sh
### BEGIN INIT INFO
# Provides:          Minecraft-Server
# Required-Start:    $all
# Required-Stop:     $remote_fs $syslog $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Starts minecraft server at boot time
# Description:       Starts minecraft server at boot time
### END INIT INFO

#dir which contains the server directory
basedir=/home/server/minecraft/

#tmux session name (`basename \"$basedir\"` -> basedir's name)
session="`basename \"$basedir\"`"

if [[ basedir != */ ]]
then
   basedir+="/"
fi

start() {
    ./tmux new-session -d -s $session
    
    echo "Starting server"
    
    ./tmux send-keys -t $session:0 "cd $basedir" C-m
    ./tmux send-keys -t $session:0 "bash start.sh" C-m
    
    echo "Server started. Attaching session..."
    
    sleep 0.5
    
    ./tmux attach-session -t $session:0
}

stop() {
    ./tmux send-keys -t $session:0 "stop" C-m
    echo "Stopping server..."
    
    for i in {5..1..-1}
    do
        echo -ne "\rWaiting for shutdown... $i"
        sleep 1
    done
    echo ""
    echo "Killing tmux session"
    ./tmux kill-session -t $session
    echo "Server stopped"
}

case "$1" in
start)
    start
;;
stop)
    stop
;;
attach)
    ./tmux attach -t $session
;;
restart)
    stop
    sleep 0.8
    echo "Restarting server..."
    sleep 0.8
    start
;;
*)
echo "Usage: start.sh (start|stop|restart|attach)"
;;
esac

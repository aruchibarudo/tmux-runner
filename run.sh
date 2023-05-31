MAX_PANE=4
OLDIFS=${IFS}
HOSTS_FILE=${1:-list.txt}
#IFS=$'\n'
HOSTS_LIST=($(cat ${HOSTS_FILE}))
y=0

CMD="cat"

tmux new-session -s tcpdump -d

for ((i=0; i < ${#HOSTS_LIST[@]}; i+=MAX_PANE))
do
  CHUNK=( "${HOSTS_LIST[@]:i:MAX_PANE}" )
  echo "Proccess ${CHUNK[*]} in window ${y}"

  CHUNK_SIZE=${#CHUNK[@]}
  COUNT_SPLIT=$((${#CHUNK[@]}-1))

  if [ ${y} -ge 1 ]
  then
    tmux new-window -t tcpdump
  fi

  for p in $(seq 1 ${COUNT_SPLIT})
  do
    tmux split-window -t tcpdump:${y} -h
  done

  tmux select-layout tiled
  
  for p in $(seq 0 ${COUNT_SPLIT})
  do
    sleep 0.5
    RUN_CMD="${CMD} ${CHUNK[${p}]}"
    echo run ${RUN_CMD} in pane ${y}.${p}
    tmux send-keys -t tcpdump:${y}.${p} "${RUN_CMD}" Enter
  done

  tmux set-window synchronize-panes on

  y=$((y+1))
done
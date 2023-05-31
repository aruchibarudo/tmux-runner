MAX_PANE=4
OLDIFS=${IFS}
HOSTS_FILE=${1:-list.txt}
OUTPUT_DIR=${2:-dump}
HOSTS_LIST=($(cat ${HOSTS_FILE}))
TMUX_SESSION=tcpdump
y=0


DEFAULT_IF="ip ro show match default | sed -nr \"s/.*dev ([^ ]+).*/\1/\""
CMD="ssh"
MY_IP=$(ip ro show match default | sed -nr "s/.*src ([^ ]+).*/\1/p")
REMOTE_CMD="'tcpdump -n -i \$(${DEFAULT_IF}) -w - -f \"not host ${MY_IP}\"'"

tmux has-session -t ${TMUX_SESSION} 2>/dev/null

if [ $? -eq 0 ]
then
  echo Session ${TMUX_SESSION} already exists
  echo "Type 'tmux attach -t ${TMUX_SESSION}' to attach it"
  exit 1
fi

mkdir -p ${OUTPUT_DIR}

tmux new-session -s ${TMUX_SESSION} -d

for ((i=0; i < ${#HOSTS_LIST[@]}; i+=MAX_PANE))
do
  CHUNK=( "${HOSTS_LIST[@]:i:MAX_PANE}" )
  echo "Proccess ${CHUNK[*]} in window ${y}"

  CHUNK_SIZE=${#CHUNK[@]}
  COUNT_SPLIT=$((${#CHUNK[@]}-1))

  if [ ${y} -ge 1 ]
  then
    tmux new-window -t ${TMUX_SESSION}
  fi

  for p in $(seq 1 ${COUNT_SPLIT})
  do
    tmux split-window -t ${TMUX_SESSION}:${y} -h
  done

  tmux select-layout tiled
  
  for p in $(seq 0 ${COUNT_SPLIT})
  do
    TARGET_HOST=${CHUNK[${p}]}
    OUTPUT_FILE="${TARGET_HOST}.pcap"
    sleep 0.5
    RUN_CMD="${CMD} ${TARGET_HOST} ${REMOTE_CMD} > ./${OUTPUT_DIR}/${OUTPUT_FILE}"
    echo run ${RUN_CMD} in pane ${y}.${p}
    tmux send-keys -t ${TMUX_SESSION}:${y}.${p} "${RUN_CMD}" Enter
  done

  tmux set-window synchronize-panes on

  y=$((y+1))
done

tmux attach -t ${TMUX_SESSION}
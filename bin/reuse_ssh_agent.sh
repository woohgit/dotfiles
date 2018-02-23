# Reuse an existing ssh-agent on login, or create a new one. Append this to your .bashrc
# I have no idea who the author of the original concept was for reusing agents. This
# version also handles the case where the agent exists but has no keys.

GOT_AGENT=0

for FILE in $(find /tmp/ssh-* -type s -user ${LOGNAME} -name "agent.[0-9]*" 2>/dev/null)
do
    SOCK_PID=${FILE##*.}

    PID=$(ps -fu${LOGNAME}|awk '/ssh-agent/ && ( $2=='${SOCK_PID}' || $3=='${SOCK_PID}' || $2=='${SOCK_PID}' +1 ) {print $2}')

    SOCK_FILE=${FILE}

    SSH_AUTH_SOCK=${SOCK_FILE}; export SSH_AUTH_SOCK;
    SSH_AGENT_PID=${PID}; export SSH_AGENT_PID;

    ssh-add -l > /dev/null
    if [ $? != 2 ]
    then
        GOT_AGENT=1
        echo "Agent pid ${PID}"
        break
    fi
    echo "Skipping pid ${PID}"

done

if [ $GOT_AGENT = 0 ]
then
    eval `ssh-agent`
fi

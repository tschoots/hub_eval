#!/bin/bash

cmd="\"echo hello\""

eval $(boot2docker shellinit)


osascript -e 'tell app "Terminal"
   do script "echo -n -e \"\\033]0;tail DATABASE\\007\";eval $(boot2docker shellinit);docker exec -ti blackduck_hub tail -f /opt/blackduck/hub/appmgr/agents/database/data/logs/bd-DatabaseAgent.log"
   do script "echo -n -e \"\\033]0;tail JobrunnerAgent\\007\";eval $(boot2docker shellinit);docker exec -ti blackduck_hub tail -f /opt/blackduck/hub/appmgr/agents/jobrunner/data/logs/bd-JobrunnerAgent.log" 
   do script "echo -n -e \"\\033]0;tail SearchAgent\\007\";eval $(boot2docker shellinit);docker exec -ti blackduck_hub tail -f /opt/blackduck/hub/appmgr/agents/search/data/logs/bd-SearchAgent.log" 
   do script "echo -n -e \"\\033]0;tail AppmgrAgent\\007\";eval $(boot2docker shellinit);docker exec -ti blackduck_hub tail -f /opt/blackduck/hub/appmgr/agents/appmgr/data/logs/bd-AppmgrAgent.log" 
   do script "echo -n -e \"\\033]0;tail HubAgent\\007\";eval $(boot2docker shellinit);docker exec -ti blackduck_hub tail -f /opt/blackduck/hub/appmgr/agents/hub/data/logs/bd-HubAgent.log" 
   #do script  "echo hello2; echo dag"
   #do script  "echo -n -e \"\\033]0;My Title\\007\""
end tell'

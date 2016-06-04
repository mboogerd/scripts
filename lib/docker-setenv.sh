exportDockerMachineEnv() {
  DESIRED_MACHINE=
  if [ -z $1 ]; then
        RUNNING_MACHINES=$(docker-machine ls | grep -i running | awk '{print $1;}');
        if (( $(grep -c . <<<"$RUNNING_MACHINES") > 1 )); then
                echo "You did not specify a docker machine name, and multiple machines are running. Please specify a machine:\n$RUNNING_MACHINES"
                exit 1
        else
                DESIRED_MACHINE=$RUNNING_MACHINES
				echo "Setting '$DESIRED_MACHINE' as target docker host"
        fi
  else
        DESIRED_MACHINE=$1
  fi

  # Iterate over the export lines and evaluate (required for zsh)
  while IFS= read -r line; do
    eval $line
  done <<<"$(docker-machine env $DESIRED_MACHINE | grep export)"
  
  export DOCKER_IP=$(docker-machine ip $DESIRED_MACHINE)
}

alias docker-setenv=exportDockerMachineEnv
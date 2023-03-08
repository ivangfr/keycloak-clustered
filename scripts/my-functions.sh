#!/usr/bin/env bash

TIMEOUT=60

# -- wait_for_container_log --
# $1: docker container name
# S2: spring value to wait to appear in container logs
function wait_for_container_log() {
  local log_waiting="Waiting for string '$2' in the $1 logs ..."
  echo "${log_waiting} It will timeout in ${TIMEOUT}s"
  SECONDS=0

  while true ; do
    local log=$(docker logs $1 2>&1 | grep "$2")
    if [ -n "$log" ] ; then
      echo $log
      break
    fi

    if [ $SECONDS -ge $TIMEOUT ] ; then
      echo "${log_waiting} TIMEOUT"
      return 1;
    fi
    sleep 1
  done
}

function test_ok() {
  echo
  echo "+---------"
  echo "| TEST OK "
  echo "+---------"
}

function test_fail() {
  echo
  echo "+-------------"
  echo "| TEST FAILED "
  echo "+-------------"
}

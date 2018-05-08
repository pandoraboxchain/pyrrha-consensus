#!/usr/bin/env bash

# Exit script as soon as a command fails.
set -o errexit

# Executes cleanup function at script exit.
trap cleanup EXIT

cleanup() {
  # Kill the ganache instance that we started (if we started one and if it's still running).
  if [ -n "$ganache_pid" ] && ps -p $ganache_pid > /dev/null; then
    kill -9 $ganache_pid
  fi
}

if [ "$SOLIDITY_COVERAGE" = true ]; then
  ganache_port=8555
else
  ganache_port=8545
fi

start_ganache() {
  if [ "$SOLIDITY_COVERAGE" = true ]; then
    npx testrpc-sc --gasLimit 0xfffffffffff --port="$ganache_port" --defaultBalanceEther=1000000 --accounts=10 > /dev/null &
  else
    npx ganache-cli --gasLimit 0xfffffffffff --port="$ganache_port" --defaultBalanceEther=1000000 --accounts=10 > /dev/null &
  fi    

  ganache_pid=$!
  echo "ganache-cli is listening on the port $ganache_port (pid: $ganache_pid)"
}

ganache_running() {
  nc -z localhost "$ganache_port"
}

if ganache_running; then
  echo "Using existing ganache instance"
else
  echo "Starting our own ganache instance"
  start_ganache
fi

if [ "$SOLIDITY_COVERAGE" = true ]; then
  npx solidity-coverage  
else
  npx --node-arg=--max-old-space-size=4096 truffle test --network ganache_cli
fi

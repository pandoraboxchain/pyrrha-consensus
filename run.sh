#!/bin/bash

truffle compile
testrpc --gasLimit=8712388
truffle deploy --network testrpc
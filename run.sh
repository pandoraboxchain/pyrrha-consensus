#!/bin/bash

truffle compile
testrpc --gasLimit=4700100 # 8712388
truffle deploy --network testrpc

npm run dev
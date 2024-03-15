#!/usr/bin/env bash

echo "Hi, this is '$0'"

set -x
eth="enp0s3"
ethtool --offload "$eth" rx off tx off
ethtool -K "$eth" gso off
ethtool -s "$eth" speed 100 duplex full
#no need to dup these here, they cause no changes:
#ethtool --offload "$eth" rx off tx off
#ethtool -K "$eth" gso off
export

echo "Bye, this was '$0'."


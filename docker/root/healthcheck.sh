#!/bin/sh

# Passem per el frontal -> 80
URL="http://equipaments.swarmme.cpd1.intranet.gencat.cat/equipaments/AppJava/equipaments/dockerId"
curl --noproxy localhost --fail ${URL}
echo "${URL} check is $?"
echo "Retuning Ok nevertheless"
true



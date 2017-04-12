#!/bin/sh

# Passem per el frontal -> 80
curl --noproxy localhost --fail http://equipaments.swarmme.cpd1.intranet.gencat.cat/equipaments/AppJava/equipaments/dockerId || exit 1



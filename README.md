# Intro
This a simple munin server container based on nginx:alpine docker image.

# Usage
## Build
    git clone https://github.com/amartinr/munin-server-docker
    cd munin-server-docker
    sudo docker build -t <tag> .

## Run
    sudo docker run -ti --name=munin --rm \
        --mount type=bind,source=$(pwd)/conf/munin-nodes.conf,destination=/etc/munin/munin-conf.d/munin-nodes.conf \
        --mount type=volume,source=munin,destination=/var/lib/munin \
        <docker-image>

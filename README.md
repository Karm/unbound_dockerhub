# unbound_dockerhub
Unbound dev build on Dockerhub; build from sources.

# Description
This is a devel build of Unbound server with Python scripting support. It compiles from [these sources](https://github.com/Karm/unbound/tree/master) and it runs in Debug mode, which is not, by default, suitable for production. One may build images based on it and alter the configuration though.

# Example usage

    docker pull karm/unbound-dockerhub

    docker run -d -p 127.0.0.1:53535:53 -p 127.0.0.1:53535:53/udp -i --name unbound karm/unbound-dockerhub

    docker logs unbound

    dig seznam.cz @127.0.0.1 -p 53535

    docker logs unbound

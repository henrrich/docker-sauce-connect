# docker-sauce-connect
This project runs SauceLabs Sauce Connect tunnel inside a docker container. It supports running Sauce Connect tunnels in the following ways:
* run a standalone unamed Sauce Connect tunnel
* run a standalone named Sauce Connect tunnel
* run a HA Sauce Connect tunnel belonging to a pool

### run a standalone unamed tunnel
Using the following docker command to start a standalone unamed tunnel:
```
docker run --rm -it -p 4445:4445 henrrich/docker-sauce-connect:latest -u <SauceLabs account> -k <SauceLabs access key>
```
When shutting down the container with `docker stop <container id>`, the tunnel will be terminated automatically. 

### run a standalone named tunnel
Using the following docker command to run a standalone named tunnel:
```
docker run --rm -it -p 4445:4445 henrrich/docker-sauce-connect:latest -u <SauceLabs account> -k <SauceLabs access key> -i <tunnel identifier>
```
To start multiple tunnels within isolated docker containers on the same host machine, different forwarding ports are needed as shown here:
```
docker run --rm -it -p 4445:4445 henrrich/docker-sauce-connect:latest -u <SauceLabs account> -k <SauceLabs access key> -i tunnel_1
docker run --rm -it -p 4446:4445 henrrich/docker-sauce-connect:latest -u <SauceLabs account> -k <SauceLabs access key> -i tunnel_2
```

### run a HA pool tunnel
To start multiple tunnels belonging to the same HA tunnel pool, the same tunnel identifier needs to be specified for all those pool tunnels, and use `-p` option to start the tunnel in pool mode:
```
docker run --rm -it -p 4445:4445 henrrich/docker-sauce-connect:latest -u <SauceLabs account> -k <SauceLabs access key> -i my_sc_pool -p
docker run --rm -it -p 4446:4445 henrrich/docker-sauce-connect:latest -u <SauceLabs account> -k <SauceLabs access key> -i my_sc_pool -p
```
Docker compose can be used to start several pool tunnels in one go. Here is an example of docker compose yml file that starts an HA tunnel pool of two tunnels:
```
version: '2'
services:
    tunnel_1:
        image: henrrich/docker-sauce-connect:latest
        restart: always
        expose: 
          - 4445
        ports: 
          - 4445
        command: -u <SauceLabs account> -k <SauceLabs access key> -i my_sc_pool -p
    tunnel_2:
        extends: tunnel_1
        depends_on:
          - "tunnel_1"
        command: -u <SauceLabs account> -k <SauceLabs access key> -i my_sc_pool -p -d 30s
```
The `-d 30s` option in the start command of the second tunnel is needed to delay the start of second HA pool tunnel for 30 seconds, so that the Sauce Connect command can detect the presence of the first tunnel with the same tunnel identifier. This is an workaround due to the lack of waiting mechanism between different docker containers.

To start the tunnel pool, run `docker-compose up`.
To stop the tunnel pool, run `docker-compose down`.

### Docker Hub
https://hub.docker.com/r/henrrich/docker-sauce-connect/

### Reference
* High Availability Sauce Connect Setup: https://wiki.saucelabs.com/display/DOCS/High+Availability+Sauce+Connect+Setup
* Using Multiple Sauce Connect Tunnels: https://wiki.saucelabs.com/display/DOCS/Using+Multiple+Sauce+Connect+Tunnels


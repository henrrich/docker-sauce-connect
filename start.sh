#!/bin/bash

cmdname=$(basename $0)

echoerr() { if [[ $QUIET -ne 1 ]]; then echo "$@" 1>&2; fi }

usage()
{
    cat << USAGE >&2
Usage:
    $cmdname -u username -k access_key [-i tunnel_id] [-p] [-d delay]
    -u username       SauceLabs username
    -k access_key     SauceLabs account access key
    -i tunnel_id      tunnel identifier
    -p                start the tunnel inside a HA tunnel pool
    -d delay          delay the start of tunnel for certain period, e.g. 5s, 2m etc

USAGE
    exit 1
}

start_pool_tunnel()
{
    exec $SC -u $USER -k $ACCESS_KEY --tunnel-identifier $TUNNEL_ID --no-remove-colliding-tunnels 
}

start_standalone_tunnel()
{
    if [[ $TUNNEL_ID == "" ]]; then
        exec $SC -u $USER -k $ACCESS_KEY
    else
        exec $SC -u $USER -k $ACCESS_KEY --tunnel-identifier $TUNNEL_ID
    fi
     
}

# process arguments
while [[ $# -gt 0 ]]
do
    case "$1" in
        -p)
        POOL=1
        shift 1
        ;;
        -u)
        USER="$2"
        if [[ $USER == "" ]]; then break; fi
        shift 2
        ;;
        -k)
        ACCESS_KEY="$2"
        if [[ $ACCESS_KEY == "" ]]; then break; fi
        shift 2
        ;;
        -i)
        TUNNEL_ID="$2"
        if [[ $TUNNEL_ID == "" ]]; then break; fi
        shift 2
        ;;
        -d)
        DELAY="$2"
        if [[ $DELAY == "" ]]; then break; fi
        shift 2
        ;;
        --help)
        usage
        ;;
        *)
        echoerr "Unknown argument: $1"
        usage
        ;;
    esac
done

if [[ "$USER" == "" || "$ACCESS_KEY" == "" ]]; then
    echoerr "Error: username and access key of SauceLabs account must be provided."
    usage
fi

SC=$workdir/bin/sc

if [[ $POOL -gt 0 ]]; then
    if [[ $DELAY != "" ]]; then
        sleep $DELAY
    fi
    start_pool_tunnel
else
    start_standalone_tunnel
fi

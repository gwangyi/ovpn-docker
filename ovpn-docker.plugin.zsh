OVPN_DATA="ovpn-data"

function ovpn-init() {
  docker volume rm $OVPN_DATA
  docker volume create --name $OVPN_DATA
  docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u tcp://hadassah.iptime.org
  docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki
}

function ovpn-run() {
  docker run -v $OVPN_DATA:/etc/openvpn -d -p 1194:1194/tcp --cap-add=NET_ADMIN kylemanna/openvpn > $HOME/.ovpn-docker
}

function ovpn-kill() {
  docker kill $(cat $HOME/.ovpn-docker) && rm $HOME/.ovpn-docker
}

function ovpn-create-client() {
  docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full $1 nopass
}

function ovpn-get-client() {
  docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn ovpn_getclient $1 > $1.ovpn
}

function ovpn-backup() {
  docker run -v $OVPN_DATA:/etc/openvpn --rm ubuntu tar cz -C /etc/openvpn . > ovpn-backup.tar.gz
}

function ovpn-restore() {
  docker run -v $OVPN_DATA:/etc/openvpn --rm -i ubuntu tar xz -C /etc/openvpn < ovpn-backup.tar.gz
}

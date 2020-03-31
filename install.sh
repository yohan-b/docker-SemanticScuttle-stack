#!/bin/bash
#Absolute path to this script
SCRIPT=$(readlink -f $0)
#Absolute path this script is in
SCRIPTPATH=$(dirname $SCRIPT)
STACK=$(basename "$SCRIPTPATH")

for VOLUME in $(awk NF $SCRIPTPATH/volume_list | tr -d "[:blank:]")
do
    systemctl enable mnt-cinder-volume@${VOLUME}.service
done

cat << EOF > /etc/systemd/system/${STACK}.service
[Unit]
Description=Starting ${STACK}
After=network-online.target firewalld.service docker.service docker.socket
Wants=network-online.target docker.service
Requires=docker.socket
EOF

for VOLUME in $(awk NF $SCRIPTPATH/volume_list | tr -d "[:blank:]")
do
    VOLUME_ESCAPED=$(systemd-escape ${VOLUME})
    cat << EOF >> /etc/systemd/system/${STACK}.service
After=mnt-cinder-volume@${VOLUME_ESCAPED}.service
After=mnt-volumes-${VOLUME_ESCAPED}.mount
Wants=mnt-cinder-volume@${VOLUME_ESCAPED}.service
Requires=mnt-volumes-${VOLUME_ESCAPED}.mount

EOF
done

cat << EOF >> /etc/systemd/system/${STACK}.service
[Service]
Type=oneshot
User=$SUDO_USER
ExecStart=$SCRIPTPATH/start.sh

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable ${STACK}.service

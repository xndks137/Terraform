cat << EOF > ~/.ssh/config
Host ${hostname}
  HostName ${hostname}
  User ${username}
  IdentityFile ${identifyfile}
EOF

chmod 600 ~/.ssh/config

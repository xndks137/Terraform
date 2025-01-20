#!/bin/bash
sudo apt -y install apache2
sudo systemctl enable --now apache2
echo "MyWEB Page" > /var/www/html/index.html
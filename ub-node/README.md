
## nginx config

sudo cp nginx.conf /etc/nginx/sites-available/proxy
sudo ls /etc/nginx/sites-available/proxy

sudo ln -s /etc/nginx/sites-available/proxy  /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

sudo service nginx restart
tail /var/log/nginx/error.log

# Generalize 
sudo waagent -deprovision+user sudo waagent -deprovision+user



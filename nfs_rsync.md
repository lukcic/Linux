https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories

NFS

Configure server:
```sh
sudo apt update
sudo apt install nfs-kernel-server
sudo mkdir /mnt/nfs_share
sudo chown -R nobody:nogroup /mnt/nfs_share
sudo chmod 777 /mnt/nfs_share

sudo vim /etc/exports
/mnt/nfs_share 192.168.254.50(rw,sync,no_subtree_check)
/mnt/nfs_share 192.168.254.0/24(rw,sync,no_subtree_check)

sudo exportfs -a
sudo systemctl restart nfs-kernel-server
$ sudo ufw allow from 192.168.254.0/24 to any port nfs
```

Configure client:
```sh
sud apt install nfs-common
sudo mkdir -p /mnt/serverpath

sudo mount 192.168.254.175:/mnt/nfs_share /mnt/serverpath
```

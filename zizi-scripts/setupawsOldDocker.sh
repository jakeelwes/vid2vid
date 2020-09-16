key=${1?Error: no key - K:SK}

#git clone https://github.com/jakeelwes/vid2vid
#docker run jakeelwes/zz

sudo apt-get update

sudo apt install s3fs


echo $key > ~/.passwd-s3fs
chmod 600 ~/.passwd-s3fs
mkdir /tmp/cache 
chmod -R 777 /tmp/cache
sudo mkdir /mnt/s3
sudo chmod -R 777 /mnt/s3

mkdir ~/vid2vid/zizi-data
chmod -R 777 ~/vid2vid/zizi-data

sudo s3fs -o use_cache=/tmp/cache -o use_path_request_style zizi.data ~/vid2vid/zizi-data -o passwd_file=~/.passwd-s3fs -o url=https://s3-eu-west-1.amazonaws.com -o umask=0777,uid=$UID -o nonempty -o allow_other

#cd vid2vid
#./zizi-data/scripts/trainAWS.sh luke-full start

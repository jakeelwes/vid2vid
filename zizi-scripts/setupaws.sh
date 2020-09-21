key=${1?Error: no key}
skey=${2?Error: no skey}
dir=${3?give dataset}
git clone https://github.com/jakeelwes/vid2vid


sudo apt-get update
sudo apt install s3fs
echo $key:$skey > ~/.passwd-s3fs
chmod 600 ~/.passwd-s3fs
mkdir /tmp/cache 
chmod -R 777 /tmp/cache
mkdir ~/vid2vid/zizi-data
chmod -R 777 ~/vid2vid/zizi-data
sudo mkdir /mnt/s3
sudo chmod -R 777 /mnt/s3

sudo s3fs -o use_cache=/tmp/cache -o use_path_request_style zizi.data /mnt/s3 -o passwd_file=~/.passwd-s3fs -o url=https://s3-eu-west-1.amazonaws.com -o umask=0777,uid=$UID -o nonempty -o allow_other

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws configure set default.region eu-west-1; aws configure set aws_access_key_id $key ; aws configure set aws_secret_access_key $skey; aws ecr get-login --no-include-email | sudo sh

cd vid2vid

mkdir ./zizi-local
mkdir ./zizi-local/$dir
mkdir ./zizi-local/checkpoints

aws s3 sync s3://zizi.data/datasets/looks/$dir ./zizi-local/$dir

(crontab -l 2>/dev/null; echo “*/15 * * * * aws s3 sync /home/jakeelwes/vid2vid/zizi-local/checkpoints/$dir s3://zizi.data/checkpoints/$dir") | crontab -





#./zizi-data/scripts/trainAWS.sh luke-full start

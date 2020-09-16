key=${1?Error: no key - K:SK}

git clone https://github.com/jakeelwes/vid2vid

sudo apt-get update
sudo apt install s3fs
echo $key > ~/.passwd-s3fs
chmod 600 ~/.passwd-s3fs
mkdir /tmp/cache 
chmod -R 777 /tmp/cache
mkdir ~/vid2vid/zizi-data
chmod -R 777 ~/vid2vid/zizi-data

sudo s3fs -o use_cache=/tmp/cache -o use_path_request_style zizi.data ~/vid2vid/zizi-data -o passwd_file=~/.passwd-s3fs -o url=https://s3-eu-west-1.amazonaws.com -o umask=0777,uid=$UID -o nonempty -o allow_other


cd vid2vid

source activate pytorch_p36

pip3 install --upgrade pip
sudo apt-get install libgl1-mesa-glx -y
pip install tqdm scipy==1.1.0 scikit-image==0.15.0 colorama==0.3.7
pip install setproctitle pytz ipython
pip install numpy==1.16.4 pillow==6.1.0
sudo apt-get install libglib2.0-0 libsm6 libxrender1 -y
pip install dominate==2.3.5 requests opencv-python==4.1.0.25 tensorflow==1.14.0

python scripts/download_flownet2.py
python scripts/download_models_flownet2.py
sudo apt-get install curl -y
curl https://download.pytorch.org/models/vgg19-dcbb9e9d.pth --create-dirs -o /root/.cache/torch/checkpoints/vgg19-dcbb9e9d.pth


#./zizi-data/scripts/trainAWS.sh luke-full start

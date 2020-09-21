source activate pytorch_p36

pip3 install --upgrade pip
sudo apt-get install libgl1-mesa-glx -y
pip install tqdm scipy==1.1.0 scikit-image==0.15.0 colorama==0.3.7
pip install setproctitle pytz ipython
pip install numpy==1.16.4 pillow==6.1.0
sudo apt-get install libglib2.0-0 libsm6 libxrender1 -y
pip install requests opencv-python==4.1.0.25
pip install --user dominate==2.3.5 tensorflow==1.14.0
sudo pip install tensorboard

python scripts/download_flownet2.py
python scripts/download_models_flownet2.py
sudo apt-get install curl -y
sudo curl https://download.pytorch.org/models/vgg19-dcbb9e9d.pth --create-dirs -o /root/.cache/torch/checkpoints/vgg19-dcbb9e9d.pth

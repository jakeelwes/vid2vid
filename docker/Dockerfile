FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

RUN apt-get update && apt-get install -y rsync htop git openssh-server

RUN apt-get install python3-pip -y
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN pip3 install --upgrade pip
RUN apt-get install libgl1-mesa-glx -y
RUN apt-get install nano

#Torch and dependencies:
#RUN pip install http://download.pytorch.org/whl/cu80/torch-0.4.0-cp35-cp35m-linux_x$
RUN pip install torch==1.1.0
RUN pip install torchvision==0.3.0 cffi==1.12.3 tensorboardX==1.8
RUN pip install tqdm scipy==1.1.0 scikit-image==0.15.0 colorama==0.3.7
RUN pip install setproctitle pytz ipython
RUN pip install numpy==1.16.4 pillow==6.1.0

#vid2vid dependencies
RUN apt-get install libglib2.0-0 libsm6 libxrender1 -y
RUN pip install dominate==2.3.5 requests opencv-python==4.1.0.25 tensorflow==1.14.0

#vid2vid install
RUN git clone https://github.com/jakeelwes/vid2vid /vid2vid
WORKDIR /vid2vid
#download flownet2 model dependencies
#WARNING: we had an instance where these scripts needed to be re-run after the docke$
RUN python scripts/download_flownet2.py
RUN python scripts/download_models_flownet2.py

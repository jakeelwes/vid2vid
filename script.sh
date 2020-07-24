
#!/bin/bash

# Make Datatset (openpose and densepose docker - will need too pull)- pick directory and test/train

PATH=${1?Error: no dir given}
tt=${2?Error: no test or train given}

# Pull docker image

echo $PATH/${tt}_img "open pose"
docker run --gpus all -v $PWD:/vid2vid --shm-size 11G openpose ./build/examples/openpose/openpose.bin \
   --image_dir /vid2vid/$PATH/${tt}_img \
   --write_images /vid2vid/$PATH/${tt}_openpose_img/ \
   --disable_blending --display 0  --write_images_format jpg \
   --write_json /vid2vid/$PATH/${tt}_openpose/ \
   --net_resolution "-1x368" --scale_number 4 --scale_gap 0.25 \
   --hand --hand_scale_number 6 --hand_scale_range 0.4 --face --face_net_resolution "368x368" --logging_level 3
    
echo $PATH/${tt}_img "dense pose"
docker run --gpus all -v $PWD:/vid2vid densepose \
    python2 tools/infer_simple.py \
    --cfg configs/DensePose_ResNet101_FPN_s1x-e2e.yaml \
    --output-dir /vid2vid/$PATH/${tt}_densepose/ \
    --image-ext jpg \
    --wts https://dl.fbaipublicfiles.com/densepose/DensePose_ResNet101_FPN_s1x-e2e.pkl /vid2vid/$PATH/${tt}_img/
    /vid2vid/$PATH/${tt}_img/


#   TRAINING


# my local docker will need to adapt from (maybe just matter of git pull)
docker run --gpus all --ipc=host -ti --volume=$PWD/zizi-show:/vid2vid/zizi-show/ --net=host vid2vid bash
# Inside docker
git pull https://github.com/jakeelwes/vid2vid #to /vid2vid

# NAME = PATH basename
# If Close: (hyperparameters could go up if AWS has more GPU VRAM - need ot be able to run locally though once trained)
python train.py --name $NAME \
    --dataroot zizi-show/datasets/$PATH --checkpoints_dir zizi-show/checkpoints/ --dataset_mode pose \
    --input_nc 6 --n_scales_spatial 1 --num_D 2 --ngf 28 --ndf 17 \
    --resize_or_crop scaleHeight --loadSize 850 --fineSize 850 \
    --no_first_img --n_frames_total 12 --max_t_step 4 --add_face_disc \
    --niter_fix_global 3 --niter 5 --niter_decay 5 \
    --lr 0.0001 --max_frames_per_gpu 1 \
    --display_freq 20 --tf_log --continue_train
    # --continue_train if have already started
    
# If Full:
python train.py --name me-bbg-test-full \
    --dataroot zizi-show/datasets/looks/me-bbg-test-full --checkpoints_dir zizi-show/checkpoints/ --dataset_mode pose \
    --input_nc 6 --n_scales_spatial 1 --num_D 2 --ngf 31 --ndf 31 \
    --resize_or_crop scaleHeight --loadSize 850 --fineSize 850 \
    --no_first_img --n_frames_total 12 --max_t_step 4 --add_face_disc \
    --niter_fix_global 3 --niter 5 --niter_decay 5 \
    --lr 0.0001 --max_frames_per_gpu 1 \
    --display_freq 20 --tf_log --continue_train
    
    
    
    
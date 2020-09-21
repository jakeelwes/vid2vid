
#!/bin/bash

# docker run --gpus all --ipc=host -ti --volume=$PWD:/vid2vid --net=host zizi:base-vid2vid bash

folder=${1?Error: no dir given}
# cf=${2?Error: no close full given}
cont=${2?Error: cont or start}

if [[ $cont = "cont" ]]
then
  conti="--continue_train"
else
  conti=""
fi

echo $folder "training"

#docker run --gpus all --shm-size 16G --volume=/mnt/s3:/vid2vid/zizi-data --volume=$PWD/zizi-scripts:/vid2vid/zizi-scripts jakeelwes/zz:latest \
    python train.py --name $(basename $folder) \
    --dataroot $folder --checkpoints_dir zizi-local/checkpoints/ --dataset_mode pose \
    --input_nc 6 --n_scales_spatial 1 --num_D 2 --ngf 29 --ndf 25 \
    --resize_or_crop scaleHeight --loadSize 850 --fineSize 850 \
    --no_first_img --n_frames_total 12 --max_t_step 4 --add_face_disc \
    --niter_fix_global 3 --niter 5 --niter_decay 5 \
    --lr 0.0001 --max_frames_per_gpu 1 --save_latest_freq 200 \
    --display_freq 100 --tf_log $conti

# Luke - Full - NGF 55 NDF 35 850

# 40 700 - 9.6G
# 30 800 - 10.9G
# 12 1000 - 10.8G

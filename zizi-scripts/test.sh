#!/bin/bash


folder=${1?Error: no dir given}
cf=${2?Error: no close full given}

echo $folder "generating"

docker run --gpus all --shm-size 11G --volume=$PWD/zizi-data:/vid2vid/zizi-data zizi:base-vid2vid \
python test.py --name $folder \
--dataroot zizi-data/datasets/acts/$cf --checkpoints_dir zizi-data/checkpoints/ --results_dir zizi-data/results/$folder \
--input_nc 6 --n_scales_spatial 1 --ngf 29 --ndf 25 --dataset_mode pose \
--resize_or_crop scaleHeight --loadSize 850 --fineSize 850 \
--tf_log --no_first_img --add_face_disc --how_many 500000 \
--start_frame 0

# 40 700 - 9.6G
# 30 800 - 10.9G
# 12 1000 - 10.8G

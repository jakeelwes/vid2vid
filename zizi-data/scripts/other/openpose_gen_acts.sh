#!/bin/bash

folder=${1?Error: no dir given}
cf=${2?Error: close full}

echo $folder "open pose"
docker run --gpus all -v $PWD:/vid2vid --shm-size 11G openpose_${cf} ./build/examples/openpose/openpose.bin \
    --image_dir /vid2vid/$folder \
    --write_images /vid2vid/$(dirname $(dirname $folder))/test_openpose_img/$(basename $folder) \
    --disable_blending --display 0  --write_images_format jpg \
    --write_json /vid2vid/$(dirname $(dirname $folder))/test_openpose/$(basename $folder) \
    --net_resolution "-1x368" --scale_number 4 --scale_gap 0.25 \
    --hand --hand_scale_number 6 --hand_scale_range 0.4 --face --face_net_resolution "480x480" --logging_level 3

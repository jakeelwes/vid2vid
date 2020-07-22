
#!/bin/bash

folder=${1?Error: no dir given}
tt=${2?Error: no test or train given}

#echo $folder/${tt}_img "open pose"
#docker run --gpus all -v $PWD:/vid2vid --shm-size 11G openpose ./build/examples/openpose/openpose.bin \
#    --image_dir /vid2vid/$folder/${tt}_img \
#    --write_images /vid2vid/$folder/${tt}_openpose_img/ \
#    --disable_blending --display 0  --write_images_format jpg \
#    --write_json /vid2vid/$folder/${tt}_openpose/ \
#    --net_resolution "-1x368" --scale_number 4 --scale_gap 0.25 \
#    --hand --hand_scale_number 6 --hand_scale_range 0.4 --face --face_net_resolution "368x368" --logging_level 3
    
echo $folder/${tt}_img "dense pose"
docker run --gpus all -v $PWD:/vid2vid densepose \
    python2 tools/infer_simple.py \
    --cfg configs/DensePose_ResNet101_FPN_s1x-e2e.yaml \
    --output-dir /vid2vid/$folder/${tt}_densepose/ \
    --image-ext jpg \
    --wts https://dl.fbaipublicfiles.com/densepose/DensePose_ResNet101_FPN_s1x-e2e.pkl /vid2vid/$folder/${tt}_img/
    /vid2vid/$folder/${tt}_img/

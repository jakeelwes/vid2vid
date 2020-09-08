
#!/bin/bash

folder=${1?Error: no dir given}

echo $folder "dense pose"
docker run --gpus all -v $PWD:/vid2vid densepose \
    python2 tools/infer_simple.py \
    --cfg configs/DensePose_ResNet101_FPN_s1x-e2e.yaml \
    --output-dir /vid2vid/$(dirname $(dirname $folder))/test_densepose/$(basename $folder) \
    --image-ext jpg \
    --wts https://dl.fbaipublicfiles.com/densepose/DensePose_ResNet101_FPN_s1x-e2e.pkl /vid2vid/$folder

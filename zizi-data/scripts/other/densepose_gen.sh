
#!/bin/bash

folder=${1?Error: no dir given}
tt=${2?Error: no test or train given}

echo $folder/${tt}_img "dense pose"
docker run --gpus all -v $PWD:/vid2vid densepose \
    python2 tools/infer_simple.py \
    --cfg configs/DensePose_ResNet101_FPN_s1x-e2e.yaml \
    --output-dir /vid2vid/$folder/${tt}_densepose/ \
    --image-ext jpg \
    --wts https://dl.fbaipublicfiles.com/densepose/DensePose_ResNet101_FPN_s1x-e2e.pkl /vid2vid/$folder/${tt}_img/
    /vid2vid/$folder/${tt}_img/

python train.py --name me-bbg-test-close \
--dataroot zizi-show/datasets/looks/me-bbg-test-close --checkpoints_dir zizi-show/checkpoints/ --dataset_mode pose \
--input_nc 6 --n_scales_spatial 1 --num_D 2 --ngf 28 --ndf 17 \
--resize_or_crop scaleHeight --loadSize 850 --fineSize 850 \
--no_first_img --n_frames_total 12 --max_t_step 4 --add_face_disc \
--niter_fix_global 3 --niter 5 --niter_decay 5 \
--lr 0.0001 --max_frames_per_gpu 1 \
--display_freq 20 --tf_log --continue_train

# 40 700 - 9.6G
# 30 800 - 10.9G
# 12 1000 - 10.8G

python test.py --name me-bbg-test-close \
--dataroot zizi-show/datasets/acts/Me-actTest-RosesTurn-Close --checkpoints_dir zizi-show/checkpoints/ --results_dir zizi-show/results/me-close-rose/ \
--input_nc 6 --n_scales_spatial 1 --ngf 28 --ndf 17 --dataset_mode pose \
--resize_or_crop scaleHeight --loadSize 850 --no_first_img --fineSize 850 \
--tf_log --no_first_img --add_face_disc --how_many 50000 \
--start_frame 0

# 40 700 - 9.6G
# 30 800 - 10.9G
# 12 1000 - 10.8G

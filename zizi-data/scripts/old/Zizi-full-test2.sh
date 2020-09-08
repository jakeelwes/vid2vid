python test.py --name me-bbg-test-full \
--dataroot zizi-show/datasets/acts/Me-actTest-RosesTurn --checkpoints_dir zizi-show/checkpoints/ --results_dir zizi-show/results/full-noface/ \
--input_nc 6 --n_scales_spatial 1 --ngf 31 --ndf 31 --dataset_mode pose \
--resize_or_crop scaleHeight --loadSize 1000 --no_first_img --fineSize 1000 \
--tf_log --no_first_img --add_face_disc --how_many 50000 \
--start_frame 0 --basic_point_only

# 40 700 - 9.6G
# 30 800 - 10.9G
# 12 1000 - 10.8G

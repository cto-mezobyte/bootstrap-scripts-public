pvcreate /dev/xvdc1
vgcreate testvg /dev/xvdc1
lvcreate -n lv_data1 --size 12G testvg
sudo mkfs -t ext4 /dev/data1/sdb1

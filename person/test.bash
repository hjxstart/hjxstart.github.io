ignoredisk --only-use=sda,nvme0n1
part /boot --fstype="xfs" --ondisk=sda --size=2048
part pv.4597 --fstype="lvmpv" --ondisk=nvme0n1 --size=30728
part /boot/efi --fstype="efi" --ondisk=sda --size=1024 --fsoptions="umask=0077,shortname=winnt"
part /mnt/dom_bin --fstype="xfs" --ondisk=sda --size=2048
part pv.1089 --fstype="lvmpv" --ondisk=sda --size=24584
part /mnt/dom_data --fstype="xfs" --ondisk=sda --size=2048
volgroup klas00 --pesize=4096 pv.1089
volgroup klas --pesize=4096 pv.4597
logvol /ftp --fstype="xfs" --size=2048 --name=ftp --vgname=klas00
logvol /tmp --fstype="xfs" --size=2048 --name=tmp --vgname=klas00
logvol swap --fstype="swap" --size=2048 --name=swap --vgname=klas00
logvol /bak --fstype="xfs" --size=5120 --name=bak --vgname=klas
logvol /dycpic --fstype="xfs" --size=2048 --name=dycpic --vgname=klas00
logvol /bis_data/rabbitmq --fstype="xfs" --size=5120 --name=bis_data_rabbitmq --vgname=klas
logvol /bis_data/mysql --fstype="xfs" --size=5120 --name=bis_data_mysql --vgname=klas
logvol /software --fstype="xfs" --size=5120 --name=software --vgname=klas
logvol /bis_data/activemq --fstype="xfs" --size=5120 --name=bis_data_activemq --vgname=klas
logvol /opt --fstype="xfs" --size=5120 --name=opt --vgname=klas
logvol / --fstype="xfs" --size=10240 --name=root --vgname=klas00
logvol /staticpic --fstype="xfs" --size=2048 --name=staticpic --vgname=klas00
logvol /pic --fstype="xfs" --size=2048 --name=pic --vgname=klas00
logvol /log --fstype="xfs" --size=2048 --name=log --vgname=klas00

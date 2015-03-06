# GlusterFS

## Mục lục

[I. Hướng dẫn sử dụng GlusterFS] (#Huongdan)

[1. Giới thiệu về GlusterFS] (#Gioithieu)

[2. Một số khái niệm khi sử dụng GlusterFS] (#Khainiem)

[3. Các loại volume trong GlusterFS] (#Cacloai)

[4. Thực hiện một số cấu hình cơ bản] (#Thuchien)
- [4.1 Chuẩn bị] (#Chuanbi)
- [4.2 Cài đặt và cấu hình trên các Server] (#Caidat)
- [4.3 Một số câu lệnh khác khi sử dụng GlusterFS] (#Motsocaulenh)
- [4.4 Cài đặt trên Client] (#CaidatCl)

[II. Sử dụng GlusterFS để làm backend cho Glance trong OpenStack] (#Sudung)
- [1. Tạo volume glusterfs trên 2 server storage] (#TaoVolume)
- [2. Cài đặt và cấu hình trên Controller node] (#CaidatController)
- [3. Kiểm tra hoạt động] (#KiemtrahoatdongGlance)

[III. Sử dụng GlusterFS làm backend cho Cinder trong OpenStack] (#BackendChoCinder)
- [1. Cài đặt và cấu hình trên 2 server GlusterFS] (#CaidatCinder)
- [2. Cài đặt và cấu hình trên Controller node] (#CaidatControllerCinder)
- [3. Cài đặt và cấu hình trên compute node] (#CaidatCompute)
- [4. Kiểm tra hoạt động] (#Kiemtrahoatdong)

[Tài liệu tham khảo] (#Tailieu)

<a name="Huongdan"></a>
## I. Hướng dẫn sử dụng GlusterFS

<a name="Gioithieu"></a>
## 1. Giới thiệu về GlusterFS 

GlusterFS là một open source, là tập hợp file hệ thống có thể được nhân rộng tới vài peta-byte và có thể xử lý hàng ngàn Client.

GlusterFS có thể linh hoạt kết hợp với các thiết bị lưu trữ vật lý, ảo, và tài nguyên điện toán đám mây để cung cấp 1 hệ thống lưu trữ có tính sẵn sàng cao và khả năng performant cao .

Chương trình có thể lưu trữ dữ liệu trên các mô hình, thiết bị khác nhau, nó kết nối với tất cả các nút cài đặt GlusterFS qua giao thức TCP hoặc RDMA tạo ra một nguồn tài nguyên lưu trữ duy nhất kết hợp tất cả các không gian lưu trữ có sẵn thành một khối lượng lưu trữ duy nhất (distributed mode) hoặc sử dụng tối đa không gian ổ cứng có sẵn trên tất cả các ghi chú để nhân bản dữ liệu của bạn (replicated mode).

<a name="Khainiem"></a>
## 2. Một số khái niệm khi sử dụng GlusterFS 

- Brick
<ul>
<li>Brick được định nghĩa bởi 1 server (name or IP) và 1 đường dẫn. Vd: 10.10.10.20:/mnt/brick (đã mount 1 partition (/dev/sdb1) vào /mnt)</li>
<li>Mỗi brick có dung lượng bị giới hạn bởi filesystem....</li>
<li>Trong mô hình lý tưởng, mỗi brick thuộc cluster có dung lượng bằng nhau.</li>
</ul>

- Volume 
<ul>
<li>Một volume là tập hợp logic của các brick</li>
<li>Tên volume được chỉ định bởi administrator</li>
<li>Volume được mount bởi client: mount -t glusterfs server1:/<volname> /my/mnt/point</li>
<li>Một volume có thể chứa các brick từ các node khác nhau.</li>
</ul>

- Node
<ul>
<li>Mỗi 1 Server đóng vai trò là 1 node trong GlusterFS</li>
</ul>

     <img src="http://i.imgur.com/vEvm0J7.png">
	 
<a name="Cacloai"></a>	 
## 3. Các loại volume trong GlusterFS 

Khi sử dụng GlusterFS có thể tạo nhiều loại volume và mỗi loại có được những tính năng khác nhau. Dưới đây là 5 loại volume cơ bản

**Distributed volume**: 

Dữ liệu được lưu trữ phân tán trên từng bricks, file1 nằm trong brick 1, file 2 nằm trong brick 2,... 

Ưu điểm: mở rộng được dung lượng store ( dung lượng store bằng tổng dung lượng các brick)

Nhược điểm: nếu 1 trong các brick bị lỗi, dữ liệu trên brick đó sẽ mất

<img src="http://i.imgur.com/ZA6d8fO.png">

**Replicated volume**: 

Dữ liệu sẽ được nhân bản đến những brick còn lại.

Ưu điểm: phù hợp với hệ thống yêu cầu tính sẵn sàng cao và dự phòng

Nhược điểm: tốn tài nguyên hệ thống

<img src="http://i.imgur.com/H9msBNH.png">

**Stripe volume**: 

Dữ liệu chia thành những phần khác nhau và lưu trữ ở những brick khác nhau, ( 1 file được chia nhỏ ra trên các brick )

Ưu điểm : phù hợp với những môi trường yêu cầu hiệu năng, đặc biệt truy cập những file lớn. 

Nhược điểm: 1 brick bị lỗi volume không thể hoạt động được.

<img src="http://i.imgur.com/nPInYen.png">

**Distributed replicated**: 

Kết hợp từ distributed và replicated 

**Distributed stripe volume**: 

Kết hợp từ Distributed và stripe. Do đó nó có hầu hết những thuộc tính hai loại trên và khi 1 node và 1 brick delete đồng nghĩa volume cũng không thể hoạt động được nữa.

**Replicated stripe volume**

Kết hợp từ replicated và stripe

<a name="Thuchien"></a>
## 4. Thực hiện một số cấu hình cơ bản 

<a name="Chuanbi"></a>
### 4.1 Chuẩn bị:

Mô hình cho bài lab này gồm nhiều server đóng vai trò như sau (mô hình có thể mở rộng cho nhiều server):

10.145.37.90  Server1

10.145.37.92  Server2

10.145.37.100 Server3

10.145.37.102 Server4

10.145.37.99  Client

Trong hệ thống GlusterFS, mỗi server được xem là 1 node trong hệ thống.

<a name="Caidat"></a>
### 4.2 Cài đặt và cấu hình trên các Server

Đầu tiên, tạo một thư mục trên 2 GlusterFS server nằm trên phân vùng khác với phân vùng / 

Ở đây, ta add thêm 1 ổ cứng mới ở cả 2 server và phân vùng, format thành định dạng xfs, mount vào /mnt 

Đầu tiên, tạo partition:

`# fdisk /dev/vdb`

Format the partition:

`# mkfs.xfs /dev/vdb1`

Mount partition vào thư mục /mnt và tạo thư mục /mnt/brick1

`# mount /dev/vdb1 /mnt && mkdir -p /mnt/brick1`

Khai báo vào file cấu hình /etc/fstab để khi restart server, hệ thống sẽ tự động mount vào thư mục.

`# echo "/dev/vdb1 /mnt xfs defaults 0 0"  >> /etc/fstab`

**Cài đặt GlusterFS:**

`# apt-get install glusterfs-server`

**Add 1 node có địa chỉ là 10.145.37.92 vào pool (đang ở trên server 10.145.37.90)**:

```
# gluster peer probe 10.145.37.92
peer probe: success
```

Trên node 10.145.37.90 cũng làm tương tự

Xem status của pool

```
# gluster peer status 
Number of Peers: 1
Hostname: 10.10.10.198
Port: 24007
Uuid: 40221832-c1a4-4a5b-ae12-8e8ddc1682d3
State: Peer in Cluster (Connected)
```

#### Taọ Volume Distributed

Tạo Volume "testvol" từ 1 node 10.145.37.90

`# gluster volume create testvol transport tcp 10.145.37.90:/mnt/brick1`

#### Tạo Volume Replicated

Tạo Volume "testvol2" từ 2 node 10.145.37.90 và 10.145.37.92 (chỉ cần tạo trên 1 trong 2 server):

`# gluster volume create testvol2 rep 2 transport tcp 10.145.37.90:/mnt/brick1 10.145.37.92:/mnt/brick1`

Đây là loại volume Replicated volume: dữ liệu sẽ được nhân bản đến những brick còn lại. Khi dữ liệu trên 1 brick bị mất (tức là dữ liệu lưu trên 1 con server) thì dữ liệu vẫn còn trên brick còn lại và tự động đồng bộ lại cho cả 2 server. Đảm bảo dữ liệu luôn đồng bộ và sẵn sàng.

Thông số rep là số lượng brick.

#### Tạo Volume Stripe

Tạo Volume "testvol3" từ 2 node 10.145.37.90 và 10.145.37.92 (chỉ cần tạo trên 1 trong 2 server):

`# gluster volume create testvol3 stripe 2 transport tcp 10.145.37.90:/mnt/brick1 10.145.37.92:/mnt/brick1`

*Note: thông số stripe là số lượng brick.*

#### Tạo Volume Distributed Replicated 

Tạo Volume Distributed Replicated từ 4 node 10.145.37.90, 10.145.37.92, 10.145.37.100, và 10.145.37.102

Đầu tiên add các node vào pool:

```
# gluster peer probe 10.145.37.92
# gluster peer probe 10.145.37.100
# gluster peer probe 10.145.37.102
```

Tạo Volume "testvol4" từ các node trên:

`# gluster volume create testvol4 replica 2 transport tcp 10.145.37.90:/mnt/brick1 10.145.37.92:/mnt/brick1 10.145.37.100:/mnt/brick1 10.145.37.102:/mnt/brick1`

*Note: Lưu ý số lượng brick là một bội số của số lượng replicated.*

#### Tạo Volume Stripe Replicated 

Tạo Volume Stripe Replicated từ 4 node có địa chỉ 10.145.37.90, 10.145.37.92, 10.145.37.100 và 10.145.37.102

Đầu tiên add các node vào pool:

```
# gluster peer probe 10.145.37.92
# gluster peer probe 10.145.37.100
# gluster peer probe 10.145.37.102
```

Tạo Volume "testvol5" từ các node trên:

`# gluster volume create testvol5 stripe 2 replica 2 transport tcp 10.145.37.90:/mnt/brick1 10.145.37.92:/mnt/brick1 10.145.37.100:/mnt/brick1 10.145.37.102:/mnt/brick1`

*Note: Lưu ý số lượng brick là một bội số của số lượng stripe*

**Start Volume:**

Sau khi tạo Volume, bạn cần phải start volume đó lên

`# gluster volume start testvol`

Bạn có thể kiểm tra lại bằng cách xem thông tin volume:	

```
# gluster volume info
Volume Name: testvol
Type: Distribute
Volume ID: 5d791191-f98c-4c24-ab23-11a0a796f714
Status: Started
Number of Bricks: 2
Transport-type: tcp
Bricks:
Brick1: 10.145.37.90:/mnt/brick1
Brick2: 10.145.37.92:/mnt/brick1
```

<a name="Motsocaulenh"></a>
### 4.3 Một số câu lệnh khác khi sử dụng GlusterFS

Add 1 node vào pool:

`# gluster peer probe <server>`

Trong đó `<server>` là địa chỉ của server mà mình muốn add vào

Xem status của pool:

`# gluster peer status`

Xóa node ra khỏi pool:

`# gluster peer detach <server>`

Trong đó `<server>` là địa chỉ của server mà mình muốn xóa

Tạo volume:

`# gluster volume create <volume-name> [stripe COUNT | replica COUNT] [transport [tcp |rdma] ] <brick1> <brick2>.... <brick n>`

Start volume:

`# gluster volume start <volume-name>`

Trong đó `<volume-name>` là tên volume cần start

Xem thông tin volume đã tạo:

`# gluster volume info`

Stop volume:

`# gluster volume stop <volume-name>` 

Trong đó `<volume-name>` là tên volume cần stop

Xóa volume:

`# gluster volume delete <volume-name>` 

Add thêm brick vào volume:

`# gluster volume add-brick <volume-name> <server:/data>`

Trong đó `<server:/data>` là đường dẫn của brick cần add, ví dụ trong bài lab trên là đường dẫn `10.145.37.92:/mnt/brick1`

Tương tự Remove brick ra khỏi volume:

`# gluster volume remove-brick <volume-name> <server:/data>` 

Migrate volume: chuyển dữ liệu từ brick này đến brick khác:

```
# gluster volume replace-brick <volume-name> <server1:/data1> <server2:/data2> start // bắt đầu chuyển dữ liệu từ brick data1 đến data2
# gluster volume replace-brick <volume-name> <server1:/data1> <server2:/data2> status // xem quá trình chuyển dữ liệu
# gluster volume replace-brick <volume-name> <server1:/data1> <server2:/data2> commit
```

Rebalance Volume: đồng bộ dữ liệu khi thêm, xóa brick:

```
# gluster volume rebalance <volume-name> fix-layout start 
# gluster volume rebalance <volume-name> migrate-data start 
# gluster volume rebalance <volume-name> start
```

<a name="CaidatCl"></a>
### 4.4 Cài đặt trên Client

`# apt-get install glusterfs-client`

Mount và sử dụng:

`# mount -t glusterfs 10.145.37.90:/testvol /mnt`

**Chú ý:** 

*Sau khi 1 brick đã được dùng để tạo 1 volume, mà brick đó đã được remove ra khỏi volume hoặc volume đó đã bị xóa thì brick đó không tạo được volume khác. Vì thế để có thể tận dụng lại những brick đó để tạo 1 volume khác, trước khi tạo volume ta phải làm như sau:*

```
# setfattr -x trusted.glusterfs.volume-id /mnt/brick1/
# setfattr -x trusted.gfid /mnt/brick1/
# rm -rf /mnt/brick1/.glusterfs
```

<a name="Sudung"></a>
## II. Sử dụng GlusterFS để làm backend cho Glance trong OpenStack

Mô hình bài lab này như sau:

<img src="http://i.imgur.com/y0Crs6W.png">

<a name="TaoVolume"></a>
#### 1. Tạo volume glusterfs "glance-volume" trên 2 server storage

Trên 2 server storage, tạo Volume Distributed "glance-volume" để làm nơi lưu trữ image cho glance trong OpenStack (có thể tạo loại volume khác tương tự như Volume Distributed)

Các bước tạo volume các bạn có thể tham khảo ở phần trên. Ở bài lab này, mình đã tạo "glance-volume"

```
Volume Name: glance-volume
Type: Distribute
Volume ID: 7bb6461c-24b1-4f23-990a-91e97b34bd9e
Status: Started
Number of Bricks: 2
Transport-type: tcp
Bricks:
Brick1: 172.16.69.197:/glance-volume/glance1
Brick2: 172.16.69.198:/glance-volume/glance1
```

<a name="CaidatController"></a>
#### 2. Cài đặt và cấu hình trên Controller node

**Cài đặt GlusterFS client:**

`# apt-get install glusterfs-client`

Tạo thư mục "glance-volume" và mount volume "glance-volume" vào thư mục đó:

```
# mkdir -p /mnt/glance-volume				
# mount -t glusterfs 172.16.69.197:/glance-volume /mnt/glance-volume/
# df -h 																		//Kiem tra
```																

**Configure Glance Service**

Đầu tiên, tạo thư mục làm nơi lưu trữ images

```
# mkdir -p /mnt/glance-volume/glance/images/  							/// Tạo thư mục lưu trữ images
# chown -R glance:glance /mnt/glance-volume/glance/						/// Cấp quyền sử dụng cho user glance
```

Chỉnh sửa file cấu hình của Glance

```
# vi /etc/glance/glance-api.conf
filesystem_store_datadir = /mnt/glance-volume/glance/images/			/// Sửa nơi lưu image thành đường dẫn storage mới tạo
```

Cuối cùng là khởi động lại dịch vụ

```
# service glance-registry restart										
# service glance-api restart
```

<a name="KiemtrahoatdongGlance"></a>
####3. Kiểm tra hoạt động

Trên Controller node, ta sẽ tải và Upload image lên hệ thống

```
# glance image-list
# mkdir /tmp/images
# wget -P /tmp/images http://cdn.download.cirros-cloud.net/0.3.3/cirros-0.3.3-x86_64-disk.img
# glance image-create --name "cirros-0.3.3-x86_64" --file /tmp/images/cirros-0.3.3-x86_64-disk.img --disk-format qcow2 --container-format bare --is-public True --progress
# glance image-list
```

Kiểm tra xem images đã được lưu vào thư mục mới tạo chưa

```
# ls /mnt/glance-volume/glance/images/
```

Bây giờ chúng ta có thể "launch instance" từ image ta mới upload lên hệ thống.

*Lưu ý: Vì image lưu ở trên 2 server storage nên khi ta umount hoặc restart lại hệ thống thì sẽ không "launch instance" được nữa. Để tránh khi restart lại, hệ thống sẽ tự động umount, ta cần khai báo trong file "fstab" dòng sau:*

`172.16.69.197:/glance-volume /mnt/glance-volume/ glusterfs defaults,_netdev 0 0`

<a name="BackendChoCinder"></a>
## III. Sử dụng GlusterFS làm backend cho Cinder trong OpenStack

Mô hình bài lab này như sau:

<img src="http://i.imgur.com/wRugJuo.png">

<a name="CaidatCinder"></a>
####1. Cài đặt và cấu hình trên 2 server GlusterFS

**Tạo volume cinder**

Đầu tiên, trên 2 server GlusterFS ta sẽ tạo volume "cinder-volume"

```
Volume Name: cinder-volume
Type: Distribute
Volume ID: 89687dba-5cde-4808-921f-f8ecbedc26b5
Status: Started
Number of Bricks: 2
Transport-type: tcp
Bricks:
Brick1: 172.16.69.197:/cinder-volume/cinder1
Brick2: 172.16.69.198:/cinder-volume/cinder1
```

**Thiết lập uid và gid cho cinder-volume**

Trên Controller node, xem uid và gid của cinder

```
# vi /etc/passwd
cinder:x:115:122::/var/lib/cinder:/bin/false
```

Thiết lập để GlusterFS volume sử dụng uid và gid giống như user cinder

```
# gluster vol set cinder-volume storage.owner-uid 115
# gluster vol set cinder-volume storage.owner-gid 122
```

**Sửa file cấu hình GlusterFS**

Khai báo thêm dòng sau trong file "glusterd.vol"

```
# vi /etc/glusterfs/glusterd.vol
option rpc-auth-allow-insecure on
```

**Khởi động lại glusterfs**

`# service glusterfs-server restart`

<a name="CaidatControllerCinder"></a>
####2. Cài đặt và cấu hình trên Controller node

**Cài đặt GlusterFS Client**

`# apt-get install glusterfs-client`

**Tạo file glusterfs**

Đầu tiên, tạo file /etc/cinder/glusterfs khai báo địa chỉ của volume "cinder-volume":

```
# vi /etc/cinder/glusterfs
172.16.69.197:/cinder-volume
```

Phân quyền cho file vừa tạo:

```
# chown root:cinder /etc/cinder/glusterfs
# chmod 0640 /etc/cinder/glusterfs
```

Tiếp đến, sửa file cấu hình của cinder bằng cách thêm các dòng sau vào [DEFAULT]

```
# vi /etc/cinder/cinder.conf

volume_driver=cinder.volume.drivers.glusterfs.GlusterfsDriver
volume_backend_name=GlusterFS
glusterfs_shares_config=/etc/cinder/glusterfs									/// Đường dẫn file glusterfs vừa tạo ở bước trên
glusterfs_mount_point_base=/var/lib/cinder/volumes								/// Giống với volumes_dir = /var/lib/cinder/volumes
glusterfs_sparsed_volumes=true
```

Khởi động lại dịch vụ cinder

```
# service cinder-api restart
# service cinder-volume restart
```

<a name="CaidatCompute"></a>
####3. Cài đặt và cấu hình trên compute node

*Nếu như chỉ cấu hình trên Controller node thì mình chỉ có thể tạo volume mà không thể attach volume vào máy ảo được. Do đó, ta cần phải cấu hình thêm ở Service Nova, bằng cách khai báo thêm diver glusterfs vào file cấu hình*

**Cài đặt GlusterFS Client**

`# apt-get install glusterfs-client`

Sửa file cấu hình của nova bằng cách thêm dòng sau vào [DEFAULT]

```
# vi /etc/nova/nova.conf

volume_drivers="glusterfs=nova.virt.libvirt.volume.LibvirtGlusterfsVolumeDriver"
```

Cuối cùng là khởi động lại dịch vụ:

`# service nova-compute restart`

<a name="Kiemtrahoatdong"></a>
####4. Kiểm tra hoạt động

**Tạo volume**

Đầu tiên ta sẽ tạo 1 volume và kiểm tra xem volume đó có phải là do GlusterFS cung cấp hay không

```
# cinder type-create glusterfs
# cinder type-list

# cinder type-key glusterfs set volume_backend_name=GlusterFS 
# cinder extra-specs-list

# cinder create --display_name disk_glusterfs --volume-type glusterfs 3
# cinder list 
```

**Kiểm tra cinder-volume**

Kiểm tra xem volume vừa tạo có được lưu tại GlusterFS Server hay không

`# ls -lah /var/lib/cinder/volumes/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/`					/// xxxxxxxxxxxxx: là chuỗi số khi tạo volume

Tiến hành attack volume vào máy ảo trên openstack

<a name="Tailieu"></a>
## Tài liệu tham khảo 

http://congdonglinux.vn/forum/showthread.php?1282-C%C3%A0i-%C4%91%E1%BA%B7t-Store-Server-s%E1%BB%AD-d%E1%BB%A5ng-GlusterFS

http://www.gluster.org/documentation/quickstart/

http://www.slideshare.net/openstackindia/glusterfs-and-openstack?related=3

http://www.slideshare.net/keithseahus/glusterfs-as-an-object-storage?related=1

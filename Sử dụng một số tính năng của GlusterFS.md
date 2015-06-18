### Sử dụng một số tính năng của GlusterFS
 
#### Cài đặt GlusterFS các phiên bản mới

Để cài đặt GlusterFS các phiên bản mới, ta cần add repository, update và tiến hành cài đặt bình thường

**Cài đặt GlusterFS bản 3.5**

```
# apt-add-repository ppa:semiosis/ubuntu-glusterfs-3.5
# apt-get update
# apt-get install gluster-server
```

**Cài đặt GlusterFS bản 3.6**

```
# apt-add-repository ppa:gluster/glusterfs-3.6
# apt-get update
# apt-get install gluster-server
```

#### Thay thế Brick (Replace brick)

Giả sử ta có volume replicate là "testvol" với 2 brick là: `172.16.69.197:/gluster1/vdb1/brick1` và `172.16.69.198:/gluster2/vdb1/brick1`

Khi node 172.16.69.198 bị lỗi, ta sẽ tiến hành remove brick của node đó ra khỏi volume và thay thế bằng 1 brick của node 172.16.69.199

remove Brick ra khỏi Volume testvol:

``` 
# gluster volume remove-brick testvol rep 1 172.16.69.198:/gluster2/vdb1/brick1 force
```

Để tiến hành thêm Brick mới vào Volume, ta cần xóa node cũ 172.16.69.198 và thêm node 172.16.69.199 vào Pool:

```
# gluster peer detach 172.16.69.198
# gluster peer probe 172.16.69.199
```

Bây giờ, ta sẽ add thêm Brick mới vào Volume:

```
# gluster volume add-brick testvol rep 2 172.16.69.199:/gluster3/vdb1/brick1    ///add thêm brick từ node .199 vào volume
```

#### Geo-replication

Với tính năng Geo-replication, ta có thể sao chép dữ liệu từ một Volume này sang một Volume khác nằm ở một vị trí địa lý khác.

Với tính năng Geo-replication, ta có thể sao chép dữ liệu từ một Volume này sang một Volume khác nằm ở một vị trí địa lý khác.

Cơ chế hoạt động như sau:

Trong mô hình dưới đây, ta có fvm1, fvm2, fvm3, fvm4, là những nodes của Volume gvm đóng vai trò là Master, fvm5, fvm6, fvm8 là những nodes của Volume gvs, đóng vai trò là Slave.

<img src="http://i.imgur.com/vyRaiOe.png">

Khi chạy câu lệnh `gluster system::execute gsec_create` trên bất kỳ node nào của Volume Master,Master Volume sẽ tạo key SSH tại `/var/lib/glusterd/geo-replication/secret.pem` cho mỗi node tại Master Volume. Tất cả public keys của Master nodes được copy tới node khởi tạo phiên kết nối và add vào file common_secret.pem.pub

<img src="http://i.imgur.com/yiuv3IF.png">

Khi chạy lệnh tạo phiên geo-replication, Master Volume sẽ kiểm tra kết nối SSH đến Slave Volume đã mở hay chưa, 

<img src="http://i.imgur.com/71VrJxK.png">

Khi đã có kết nối SSH giữa 2 Volume, tiếp đến sẽ kiểm tra phiên bản Gluster, kích thước giữa 2 Volume

<img src="http://i.imgur.com/BrvIKAw.png">

Sau khi hoàn thành các bước kiểm tra, Master Volume sẽ copy file `common_secret pub` tới 1 nodes của Slave Volume, phân phối tới các node còn lại và add authorized_keys tới mỗi nodes tại Slave Volume
Kết thúc việc khởi tạo phiên geo-replication, bây giờ ta có thể bắt đầu phiên geo-replication để sao chép dữ liệu.

**Các bước thực hiện:**

Tạo 2 volume tại 2 vị trí khác nhau (khác pool) 2 volume phải cùng loại và cùng kích thước

Tại Node Gluster01 tạo volume như sau:

```
root@Gluster01:/gluster1/vdb1/brick-197# gluster vol in

Volume Name: geo-rep
Type: Distribute
Volume ID: 74715e39-7b98-4ee1-88db-448928a19aaf
Status: Started
Number of Bricks: 1
Transport-type: tcp
Bricks:
Brick1: 10.10.10.197:/gluster1/vdb1/brick-197
```

Tại Node Gluster02 tạo volume như sau:

```
root@Gluster02:/gluster1/vdb1/brick-198# gluster vol in

Volume Name: geo-rep2
Type: Distribute
Volume ID: 70d3bb23-d3af-4359-8d93-1376eac438d7
Status: Started
Number of Bricks: 1
Transport-type: tcp
Bricks:
Brick1: 10.10.10.198:/gluster1/vdb1/brick-198
```

Tại bài lab này, Node Gluster01 sẽ đóng vai trò là Master còn node Gluster02 là Slave. Dữ liệu từ Master sẽ được sao chép sang Slave

**B1: Tạo phiên kết nối SSH**

Tạo kết nối SSH từ Master đến node Slave

Trên Node Gluster01

Tạo key

```
root@Gluster01:~# ssh-keygen -t rsa

Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): [Press enter key]
Created directory '/root/.ssh'.
Enter passphrase (empty for no passphrase): [Press enter key]
Enter same passphrase again: [Press enter key]
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
```

*Chú ý: khi tạo key, ta sẽ để lưu vào đường dẫn mặc định và không đặt passphrase*

Kết nối đến Gluster02 và tạo thư mục .ssh

```
root@Gluster01:~# ssh root@Gluster02 mkdir -p .ssh
```

Từ Node Gluster01, gửi key sang Gluster02 và lưu vào file Authorized

```
root@Gluster01:~# cat .ssh/id_rsa.pub | ssh root@Gluster02 'cat >> .ssh/authorized_keys'

root@Gluster02's password: [Enter Your Password Here]
```

Phân quyền cho các thư mục ssh tại Node Gluster02

```
root@Gluster01:~# ssh root@Gluster02 "chmod 700 .ssh; chmod 640 .ssh/authorized_keys"

root@Gluster02's password: [Enter Your Password Here]
```

Test SSH từ Node Gluster01 đến Gluster02

`root@Gluster01:~# ssh sheena@192.168.0.11`

Nếu không cần nhập pass thì bước tạo kết nối SSH thành công, exit và thực hiện các bước tiếp theo.

Có thể tham khảo thêm bước này tại đây: http://www.tecmint.com/ssh-passwordless-login-using-ssh-keygen-in-5-easy-steps/

**B2: Đồng bộ thời gian giữa 2 node (có thể cài NTP)**

**B3: Tạo phiên geo-replication**

`# gluster system:: execute gsec_create`

`# gluster volume geo-replication MASTER_VOL SLAVE_HOST::SLAVE_VOL create push-pem [force]`

ví dụ:

```
# gluster system:: execute gsec_create
# gluster vol geo-replication geo-rep gluster02::geo-rep2 create push-pem
```

Kiểm tra phiên geo-replication

`# gluster vol geo-replication geo-rep gluster02::geo-rep2 status`

Copy các flie cấu hình tại thư mục mặc định của Ubuntu sang thư mục đã khai báo 

```
# cd /usr/
# mkdir libexec
# cd libexec/
# cp -R /usr/lib/x86_64-linux-gnu/glusterfs/ .
```

Bắt đầu phiên geo-replication

```
#gluster vol geo-replication geo-rep gluster02::geo-rep2 start
#gluster vol geo-replication geo-rep gluster02::geo-rep2 status
```

#### Khôi phục dữ liệu:
(Sử dụng rsync)

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


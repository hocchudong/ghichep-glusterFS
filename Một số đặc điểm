#### Một số đặc điểm nổi bật khi triển khai GlusterFS

Một số đặc điểm nồi bật:
- Không có Metadata server: Khác với Ceph, GlusterFS không sử dụng Metadata server do đó nó có thể tránh việc khi truy xuất dữ liệu đều phải đi qua Metadata server dẫn đến tình trạng "thắt cổ chai" và khi metadata server bị hỏng thì sẽ không truy xuất đến dữ liệu được. (GlusterFS sử dụng cơ chế hashing)
- Khả năng co giãn: Storage volume có thể được mở rộng, thu nhỏ, hoặc dy chuyển qua các hệ thống vật lý khác khi cần thiết. Các Storage server có thể được thêm vào hoặc gỡ bỏ khỏi hệ thống, với dữ liệu được đồng bộ lại trên pool của hệ thống.
- Tính sẵn sàng cao
- Khả năng linh hoạt: Có thể cấu hình lại các đặc tính về lưu trữ thích hợp cho từng hoàn cảnh sử dụng (ví dụ cấu hình replicated volume cho trường hợp lưu trữ những dữ liệu quan trọng)
- Geo-replication: Sao chép dữ liệu giữa những hệ thống lưu trữ nằm ở vị trí khác nhau.
- GlusterFS không chia sẻ được 1 file cụ thể trong storage volume.

#### Một số giải pháp được xây dựng dựa trên GlusterFS

Triển khai hệ thống:
- Media serving (CDN): Là hệ thống lưu trữ dữ liệu bao gồm các ứng dụng web, file tải xuống (âm thanh, hình ảnh, phần mềm, tài liệu,…), truyền tải thời gian thực.
- Large scale file storage: Hệ thống lưu trữ file quy mô lớn
- File sharing: Hệ thống chia sẻ file
- High Performance Computing (HPC) storage: Cung cấp hệ thống lưu trữ hiệu năng cao
- IaaS storage layer: Cung cấp storage như 1 dịch vụ (hdd, ssd ảo...)
- Được sử dụng để làm backend cho Glance, Cinder, Swift trong OpenStack.

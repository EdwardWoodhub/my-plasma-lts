# EL 10 bootc 镜像的桌面支持与生态限制

这两个镜像（quay.io/centos-bootc/centos-bootc:stream10和quay.io/almalinuxorg/almalinux-bootc:10）定位均为面向服务器与边缘计算的最小化基础系统，官方并未提供任何预装桌面的同类基座；虽然支持自行在 `Containerfile` 中叠加图形环境，但因 Enterprise Linux 10 全面放弃 X11 转向 Wayland 且软件库高度保守，官方与 EPEL 资源基本仅集中维护 GNOME 和 KDE Plasma，对于 labwc、LXQt 等高度依赖较新 wlroots 库的小众合成器和轻量桌面几乎没有打包支持，自行编译极其繁琐且易陷入依赖地狱，因此搭建此类极简或定制化桌面时，依赖链完整且更新及时的 `fedora-bootc` （quay.io/fedora/fedora-bootc:latest）依然是不可替代的最佳选择。

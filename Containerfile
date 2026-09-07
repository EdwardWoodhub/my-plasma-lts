# 1. 继承红帽官方纯正 CentOS Stream 10 底座 (锁定纯正 .el10 内核)
FROM quay.io/centos-bootc/centos-bootc:stream10

# 2. 启用 EPEL 10、CRB、RPM Fusion 与 Terra 仓库
RUN dnf install -y --setopt=install_weak_deps=False \
        epel-release \
        dnf-plugins-core && \
    dnf config-manager --set-enabled crb && \
    # 添加 Terra 10 软件源 (提供 Nerd Fonts、更纱黑体、ms-core-fonts)
    # dnf config-manager --add-repo https://repos.fyralabs.com/terra10 && \
    # 启用 RPM Fusion 源 (提供多媒体 Codec 与 VLC)
    dnf install -y --nogpgcheck \
        https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-10.noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-10.noarch.rpm

# 3. 安装指定的 RPM 软件包
RUN dnf install -y \
    btop \
    dbus-x11 \
    dolphin \
    fira-code-fonts \
    flatpak \
    firefox \
    fastfetch \
    fontconfig \
    gedit \
    git \
    gwenview \
    glx-utils \
    htop \
    jetbrains-mono-fonts-all \
    kate \
    kscreen \
    konsole \
    kwin \
    libwebp \
    libheif \
    liberation-mono-fonts \
    mesa-dri-drivers \
    open-vm-tools \
    open-vm-tools-desktop \
    polkit-kde \
    plasma-workspace \
    plasma-desktop \
    plasma-firewall-firewalld \
    qt6-qtimageformats \
    sddm \
    spectacle \
    syncthing \
    vlc \
    wqy-zenhei-fonts \
    xdg-desktop-portal \
    xdg-user-dirs \
    xorg-x11-server-Xwayland && \
    # --- Terra 字体包 ---
    # adobe-source-han-sans-fonts \
    # cascadiacode-nerd-fonts \
    # iosevka-nerd-fonts \
    # liberationmono-nerd-fonts \
    # ms-core-fonts \
    # noto-nerd-fonts \
    # sarasa-gothic-fonts \
    fc-cache -fv && \
    dnf clean all && \
    rm -rf /var/cache/dnf/* /tmp/* /var/tmp/*

# 4. 配置默认启动目标为图形界面，并启用 SDDM 显示管理器
RUN systemctl set-default graphical.target && \
    systemctl enable sddm.service

# 启用服务开机自启（在容器构建阶段生效）
RUN systemctl enable vmtoolsd.service

# 5. 配置 Flathub 软件源
RUN flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 6. 生成 Flatpak 开机预装脚本 (已加入坚果云)
RUN mkdir -p /usr/libexec/my-custom-setup && \
    printf '%s\n' \
      '#!/usr/bin/env bash' \
      'set -e' \
      'FLATPAKS=(' \
      '  com.google.Chrome' \
      '  com.visualstudio.code' \
      '  com.github.tchx84.Flatseal' \
      '  org.mozilla.firefox' \
      '  io.missioncenter.MissionCenter' \
      '  com.jianguoyun.Nutstore' \
      '  io.github.peazip.PeaZip' \
      '  net.nokyan.Resources' \
      '  com.xnview.XnViewMP' \
      ')' \
      'for app in "${FLATPAKS[@]}"; do' \
      '  flatpak install --system -y --noninteractive flathub "$app" || true' \
      'done' \
      > /usr/libexec/my-custom-setup/install-flatpaks.sh && \
    chmod +x /usr/libexec/my-custom-setup/install-flatpaks.sh

# 7. 注册开机一次性预装 systemd 服务
RUN printf '%s\n' \
      '[Unit]' \
      'Description=Pre-install default system Flatpaks' \
      'After=network-online.target' \
      'Wants=network-online.target' \
      'ConditionPathExists=!/var/lib/flatpaks-installed.stamp' \
      '' \
      '[Service]' \
      'Type=oneshot' \
      'ExecStart=/usr/libexec/my-custom-setup/install-flatpaks.sh' \
      'ExecStartPost=/usr/bin/touch /var/lib/flatpaks-installed.stamp' \
      'RemainAfterExit=yes' \
      '' \
      '[Install]' \
      'WantedBy=multi-user.target' \
      > /etc/systemd/system/preinstall-flatpaks.service && \
    systemctl enable preinstall-flatpaks.service

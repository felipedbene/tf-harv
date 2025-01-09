# Variables
{% set platform = "arm64" if grains['osarch'] == "aarch64" else "amd64" %}
{% set containerd_version = salt['cmd.run']('curl -s https://api.github.com/repos/containerd/containerd/releases/latest | jq -r ".tag_name"').lstrip('v') %}
{% set runc_version = salt['cmd.run']('curl -s https://api.github.com/repos/opencontainers/runc/releases/latest | jq -r ".tag_name"') %}

# Install dependencies
install_dependencies:
  pkg.installed:
    - names:
      - jq
      - wget

# Load kernel modules for container runtime
load_container_modules_conf:
  file.managed:
    - name: /etc/modules-load.d/containerd.conf
    - contents: |
        overlay
        br_netfilter
    - mode: 644

load_container_modules_now:
  cmd.run:
    - name: |
        modprobe overlay
        modprobe br_netfilter
    - unless: lsmod | grep -E 'overlay|br_netfilter'

# Configure sysctl
configure_sysctl_file:
  file.managed:
    - name: /etc/sysctl.d/99-kubernetes-cri.conf
    - contents: |
        net.bridge.bridge-nf-call-iptables  = 1
        net.ipv4.ip_forward                 = 1
        net.bridge.bridge-nf-call-ip6tables = 1
    - mode: 644

apply_sysctl:
  cmd.run:
    - name: sysctl --system

# Download and install containerd
install_containerd:
  cmd.run:
    - name: |
        CONTAINERD_VERSION=$(curl -s https://api.github.com/repos/containerd/containerd/releases/latest | jq -r '.tag_name' | sed 's/^v//')
        wget https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-{{ platform }}.tar.gz &&
        tar xvf containerd-${CONTAINERD_VERSION}-linux-{{ platform }}.tar.gz -C /usr/local
    - unless: test -x /usr/local/bin/containerd


# Create containerd configuration directory
create_containerd_config_dir:
  file.directory:
    - name: /etc/containerd
    - mode: 755

# Configure containerd
configure_containerd:
  file.managed:
    - name: /etc/containerd/config.toml
    - contents: |
        version = 2
        [plugins]
          [plugins."io.containerd.grpc.v1.cri"]
            [plugins."io.containerd.grpc.v1.cri".containerd]
              discard_unpacked_layers = true
              [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
                [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
                  runtime_type = "io.containerd.runc.v2"
                  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
                    SystemdCgroup = true
    - mode: 644

# Download and install runc
install_runc:
  cmd.run:
    - name: |
        RUNC_VERSION=$(curl -s https://api.github.com/repos/opencontainers/runc/releases/latest | jq -r '.tag_name')
        wget https://github.com/opencontainers/runc/releases/download/${RUNC_VERSION}/runc.{{ platform }} &&
        install -m 755 runc.{{ platform }} /usr/local/sbin/runc
    - unless: test -x /usr/local/sbin/runc


# Setup and enable containerd service
download_containerd_service:
  cmd.run:
    - name: |
        wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service &&
        mv containerd.service /usr/lib/systemd/system/
    - unless: test -f /usr/lib/systemd/system/containerd.service

enable_containerd_service:
  service.running:
    - name: containerd
    - enable: True

# Disable AppArmor for runc
disable_apparmor:
  cmd.run:
    - name: |
        ln -s /etc/apparmor.d/runc /etc/apparmor.d/disable/ &&
        apparmor_parser -R /etc/apparmor.d/runc
    - unless: test -L /etc/apparmor.d/disable/runc


# Reboot system after all states
# reboot_system:
#   cmd.run:
#     - name: systemctl reboot
#     - onlyif:
#       - systemctl is-active --quiet containerd



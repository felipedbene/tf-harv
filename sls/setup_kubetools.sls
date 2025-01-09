install_dependencies:
  pkg.installed:
    - pkgs:
        - apt-transport-https
        - ca-certificates
        - curl
        - gnupg

setup_k8s_repo:
  cmd.run:
    - name: |
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | \
        gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    - unless: test -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg

import_repo_key:
  cmd.run:
    - name: |
        gpg --no-default-keyring --keyring /etc/apt/keyrings/kubernetes-apt-keyring.gpg --list-keys >/dev/null || \
        gpg --no-default-keyring --keyring /etc/apt/keyrings/kubernetes-apt-keyring.gpg --recv-keys 234654DA9A296436
    - require:
        - cmd: setup_k8s_repo

add_k8s_source:
  file.managed:
    - name: /etc/apt/sources.list.d/kubernetes.list
    - contents: deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /
    - mode: 0644
    - require:
        - cmd: import_repo_key

update_apt_sources:
  cmd.run:
    - name: apt-get update
    - onchanges:
        - file: add_k8s_source

install_k8s_tools:
  pkg.installed:
    - pkgs:
        - kubelet
        - kubeadm
        - kubectl
    - require:
        - cmd: update_apt_sources

hold_k8s_tools:
  cmd.run:
    - name: apt-mark hold kubelet kubeadm kubectl
    - require:
        - pkg: install_k8s_tools

install_crictl:
  cmd.run:
    - name: |
        VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/cri-tools/releases/latest | grep tag_name | cut -d '"' -f 4) && \
        curl -LO https://github.com/kubernetes-sigs/cri-tools/releases/download/${VERSION}/crictl-${VERSION}-linux-amd64.tar.gz && \
        tar -C /usr/local/bin -xzf crictl-${VERSION}-linux-amd64.tar.gz && \
        rm -f crictl-${VERSION}-linux-amd64.tar.gz
    - unless: test -f /usr/local/bin/crictl

disable_swap:
  cmd.run:
    - name: swapoff -a
    - unless: 'free | grep -q "Swap: *0B"'


update_fstab:
  file.replace:
    - name: /etc/fstab
    - pattern: '^(/swap)'
    - repl: '#\1'
    - require:
        - cmd: disable_swap

set_crictl_runtime:
  cmd.run:
    - name: crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock
    - unless: crictl config --get runtime-endpoint | grep -q 'unix:///run/containerd/containerd.sock'

post_install_message:
  cmd.run:
    - name: echo 'Follow the instructions to initialize control node and apply Calico plugin.'

setup_k8s_master:
  cmd.run:
    - name: kubeadm init
    - creates: /etc/kubernetes/admin.conf

setup_kubectl:
  file.managed:
    - name: /root/.kube/config
    - source: salt://k8s/master/admin.conf
    - makedirs: True
    - require:
      - cmd: setup_k8s_master

install_calico:
  cmd.run:
    - name: >
        kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
    - cwd: /root
    - env:
        KUBECONFIG: /root/.kube/config
    - require:
      - cmd: setup_k8s_master

save_join_command:
  cmd.run:
    - name: >
        kubeadm token create --print-join-command > /srv/salt/k8s/join_command.txt
    - unless: test -f /srv/salt/k8s/join_command.txt
    - require:
      - cmd: install_calico

share_join_command:
  file.managed:
    - name: /srv/salt/k8s/join_command.txt
    - source: salt://k8s/join_command.txt
    - makedirs: True
    - require:
      - cmd: save_join_command

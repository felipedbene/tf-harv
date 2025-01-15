fetch_join_command:
  cmd.script:
    - name: salt://k8s/get_join_command.sh
    - output_loglevel: debug

join_k8s_cluster:
  cmd.run:
    - name: sh /tmp/kubeadm_join_cmd.sh
    - onlyif: test -f /tmp/kubeadm_join_cmd.sh

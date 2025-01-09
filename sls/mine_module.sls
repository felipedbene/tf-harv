configure_mine_functions:
  file.blockreplace:
    - name: /etc/salt/minion
    - marker_start: "# MINE FUNCTIONS START"
    - marker_end: "# MINE FUNCTIONS END"
    - content: |
        mine_functions:
          network.ip_addrs: []
    - append_if_not_found: True
    - backup: True

restart_minion_service:
  service.running:
    - name: salt-minion
    - enable: True
    - watch:
      - file: configure_mine_functions

{% set hosts = salt['mine.get']('*', 'network.ip_addrs') %}

# Ensure /etc/hosts has correct permissions
/etc/hosts:
  file.managed:
    - user: root
    - group: root
    - mode: '0644'
    - contents: |
        # Managed by Salt
        127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4
        ::1 localhost localhost.localdomain localhost6 localhost6.localdomain6
        
        # Salt Master (static entry)
        10.0.2.65 salt
        
        # Managed Salt Minions
        {%- for minion_id, ips in hosts.items() %}
        {%- if ips %}
        {{ ips[0] }} {{ minion_id }}
        {%- endif %}
        {%- endfor %}
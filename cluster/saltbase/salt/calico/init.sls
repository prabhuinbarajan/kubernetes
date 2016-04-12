calico:
  pkg:
    - installed
  service:
    - running
    - watch:
      - pkg: calico
      - file: /etc/cni/net.d/10-calico.conf 

/etc/cni/net.d/10-calico.conf.template:
  file:
    - managed
    - source:  salt://calico/10-calico.conf.template
    - makedirs: true
    - dir_mode: 755
    - user: root
    - group: root
    - mode: 644

/opt/cni/bin/calico:
  file:
    - managed
    - source:  salt://calico/calico
    - makedirs: true
    - dir_mode: 755
    - user: root
    - group: root
    - mode: 700

calico-init:
  cmd.script:
    - require:
      - file: /etc/cni/net.d/10-calico.conf.template
    - require_in:
      - file: {{ pillar.get('systemd_system_path') }}/calico-node.service
    - source: salt://calico/calico-gen-conf.sh
    - cwd: /etc/cni/net.d/
    - user: root
    - group: root
    - mode: 700
    - shell: /bin/bash

{% if pillar.get('is_systemd') %}

{{ pillar.get('systemd_system_path') }}/calico-node.service:
  file.managed:
    - source: salt://calico/calico-node.service
    - user: root
    - group: root

# The service.running block below doesn't work reliably
# Instead we run our script which e.g. does a systemd daemon-reload
# But we keep the service block below, so it can be used by dependencies
# TODO: Fix this
fix-service-calico:
  cmd.wait:
    - name: /opt/kubernetes/helpers/services bounce calico-node
    - watch:
      - file: {{ pillar.get('systemd_system_path') }}/calico-node.service
{% endif %}

calico-node:
  service.running:
    - enable: True
    - watch:
{% if pillar.get('is_systemd') %}
      - file: {{ pillar.get('systemd_system_path') }}/calico-node.service
{% endif %}
{% if pillar.get('is_systemd') %}
    - provider:
      - service: systemd
{%- endif %}

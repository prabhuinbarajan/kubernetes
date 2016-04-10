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

calico-init:
  cmd.script:
    - require:
      - file: /etc/cni/net.d/10-calico.conf.template
    - source: salt://calico/calico-gen-conf.sh
    - cwd: /etc/cni/net.d/
    - user: root
    - group: root
    - mode: 700
    - shell: /bin/bash

{% if 'act' in data and data['act'] == 'pend' and data['id'].startswith(salt['grains.get']('stack:stackname')) %}
minion_add:
  wheel.key.accept:
    - match: {{ data['id'] }}
{% endif %}

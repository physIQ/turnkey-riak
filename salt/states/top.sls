base:
 '*':
  - common.misc
  - common.beaver
{% set instance_profiles = salt['grains.get']('stack:profiles', []) %}
{% for profile in instance_profiles %}
  - profiles.{{ profile }}
{% endfor %}


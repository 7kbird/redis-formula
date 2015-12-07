{% set docker_images = [] %}

{% for name, docker in salt['pillar.get']('redis:dockers', {}).items() %}
{% set docker_image = docker.get('image', 'sameersbn/redis')%}
{% set docker_image = docker_image ~ ':latest' if ':' not in docker_image %}
{% do docker_images.append(docker_image) if docker_image not in docker_images %}

redis-docker-running_{{ name }}:
  dockerng.running:
    - name: {{ name }}
    - image: {{ docker_image }}
    - binds: {{ docker.get('binds', '/srv/docker/redis/' ~  name  ~ ':/var/lib/redis') }}
    - require:
      #- dockerng: redis-docker-image_{{ docker_image }}
      - cmd: redis-docker-image_{{ docker_image }}

{% endfor %}

{% for image in docker_images %}

redis-docker-image_{{ image }}:
  #  dockerng.image_present:    # FIXME: dockerng does not support public repo, see #28004
  #  - name: {{ image }}
  cmd.run:
    - name: docker pull {{ image }}
    - unless: '[ $(docker images -q {{ image }}) ]'
{% endfor %}

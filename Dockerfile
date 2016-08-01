# Ubuntu Redis.

FROM ubuntu:16.04
MAINTAINER Thomas Quintana <thomas@inteliquent.com>

# Add the latest stable redis ppa.
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository ppa:chris-lea/redis-server

# Install Redis.
RUN apt-get update && apt-get install -y redis-server

# Install Dependencies and Tools.
RUN apt-get install -y cron logrotate python python-dev python-pip

# Install Python Tools.
RUN pip install --upgrade pip
RUN pip install trt

# Clean Up.
RUN apt-get autoremove && apt-get autoclean

# Add the Redis templates to the container.
RUN mkdir -p /usr/share/redis/3.2.2
ADD templates/redis/redis.conf.template /usr/share/redis/3.2.2/redis.conf.template
ADD templates/redis/sentinel.conf.template /usr/share/redis/3.2.2/sentinel.conf.template

# Add the logrotate configuration.
ADD templates/logrotate/logrotate.conf /etc/logrotate.conf
ADD templates/logrotate/redis /etc/logrotate.d/redis

# Add the Linux templates to the container.
ADD templates/linux/sysctl.conf /etc/sysctl.optimized.conf

# Copy and register the sentinel sysv script.
ADD sysv/sentinel-server /etc/init.d/sentinel-server
RUN chmod +x /etc/init.d/sentinel-server
RUN update-rc.d -f sentinel-server defaults

# Open the container up to the world.
EXPOSE 6379/tcp
EXPOSE 26379/tcp

# Initialize the container and start the Redis Server.
CMD /bin/bash -c " \
  if [ -z ${REDIS_OPTIMIZED+x} ];then \
    echo 'Redis Container Optimization Disabled.'; \
  else \
    REDIS_OPTIMIZED=`echo $REDIS_OPTIMIZED | awk '{print tolower($0)}'`; \
    if [ $REDIS_OPTIMIZED=true ];then \
      echo never > /sys/kernel/mm/transparent_hugepage/enabled; \
      sysctl -p /etc/sysctl.optimized.conf; \
    fi; \
  fi; \
  if [ -z ${REDIS_INIT+x} ];then \
    echo 'Launching Default Configuration.'; \
  else \
    REDIS_INIT=`echo $REDIS_INIT | awk '{print tolower($0)}'`; \
    if [ $REDIS_INIT=true ];then \
      echo 'Initializing the Redis 3.2.2 Container.'; \
      trt -s /usr/share/redis/3.2.2/redis.conf.template \
          -d /etc/redis/redis.conf \
          -ps environment; \
      chown redis:redis /etc/redis/redis.conf; \
      if [ ! -z ${REDIS_SENTINEL_ENABLED+x} ];then \
        REDIS_SENTINEL_ENABLED=`echo $REDIS_SENTINEL_ENABLED | awk '{print tolower($0)}'`; \
        if [ $REDIS_SENTINEL_ENABLED=true ];then \
          trt -s /usr/share/redis/3.2.2/sentinel.conf.template \
              -d /etc/redis/sentinel.conf \
              -ps environment; \
          chown redis:redis /etc/redis/sentinel.conf; \
        fi; \
      fi; \
    fi; \
  fi; \
  service redis-server start; \
  if [ -z ${REDIS_SENTINEL_ENABLED+x} ];then \
    echo 'Redis Sentinel Service Disabled.'; \
  else \
    REDIS_SENTINEL_ENABLED=`echo $REDIS_SENTINEL_ENABLED | awk '{print tolower($0)}'`; \
    if [ $REDIS_SENTINEL_ENABLED=true ];then \
      service sentinel-server start; \
    fi; \
  fi; \
  tail -f /var/log/redis/redis-server.log; \
"

FROM whyour/qinglong:2.22.0-debian
EXPOSE 5700
ENTRYPOINT ["./docker/docker-entrypoint.sh"]

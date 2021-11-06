#! /bin/bash
sudo apt-get update
#sudo apt-get install -y apache2
#sudo systemctl start apache2
#sudo systemctl enable apache2
#echo "<h1>Azure Linux VM with Web Server</h1>" | sudo tee /var/www/html/index.html

# Install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce
sudo sysctl -w vm.max_map_count=262144

curl -o /tmp/Geolite2-ASN.mmdb -s --fail --retry 60 -m 10 -L https://raw.githubusercontent.com/skenderidis/demo/main/Demo-1/Geolite2-ASN.mmdb
curl -o /tmp/Geolite2-City.mmdb -s --fail --retry 60 -m 10 -L https://raw.githubusercontent.com/skenderidis/demo/main/Demo-1/Geolite2-City.mmdb
curl -o /tmp/GeoLite2-Country.mmdb -s --fail --retry 60 -m 10 -L https://raw.githubusercontent.com/skenderidis/demo/main/Demo-1/Geolite2-Country.mmdb


cat << 'EOF' > /tmp/prometheus.yml
# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).
 
# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093
 
# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"
 
# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
 
  - job_name: 'f5'
    scrape_interval: 20s
    metrics_path: '/mgmt/shared/telemetry/namespace/Stats/pullconsumer/Prometheus'
    scheme: 'https'
    tls_config:
      insecure_skip_verify: true
    basic_auth:
      username: '${username}'
      password: '${password}'
    dns_sd_configs:
    - names:
      - bigip.f5demo.cloud
      type: 'A'
      port: 443

    relabel_configs:
      - source_labels: [__meta_dns_host]
        target_label: instance

# The type of DNS query to perform. One of SRV, A, or AAAA.
#        [ type: A ]
# | default = 'SRV' ]

# The port number used if the query type is not SRV.
#      [ port: 443]

# The time after which the provided names are refreshed.
#[ refresh_interval: <duration> | default = 30s ]
EOF



# Start the f5-demo-httpd container
cat << 'EOF' > /etc/rc.local
#!/bin/sh -e
docker network create elastic
docker run --name elastic --net elastic -d -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -e ES_HEAP_SIZE="3g" --restart unless-stopped docker.elastic.co/elasticsearch/elasticsearch:6.8.20
docker run --name kibana --net elastic -d -p 5601:5601 -e "ELASTICSEARCH_HOSTS=http://elastic:9200" --restart unless-stopped docker.elastic.co/kibana/kibana:6.8.20
docker run --name grafana --net elastic -d -p 8080:3000 --restart unless-stopped grafana/grafana
docker run --name prometheus --net elastic -d -p 9090:9090 -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus

docker cp  /tmp/GeoLite2-Country.mmdb d190bff282c3:/usr/share/elasticsearch/modules/ingest-geoip/
docker cp  /tmp/GeoLite2-City.mmdb d190bff282c3:/usr/share/elasticsearch/modules/ingest-geoip/
docker cp  /tmp/GeoLite2-ASN.mmdb d190bff282c3:/usr/share/elasticsearch/modules/ingest-geoip/
EOF

sh /etc/rc.local
cd ~/workspace

[[ -s "~/.rvm/scripts/rvm" ]] && source "~/.rvm/scripts/rvm"  # Load RVM

export WORKSPACE=~/workspace

export http_proxy=proxy.co.uk:80
export HTTP_PROXY=proxy.co.uk:80
export https_proxy=proxy.co.uk:80
export HTTPS_PROXY=proxy.co.uk:80
export ftp_proxy=ftp.proxy.co.uk:80
export ALL_PROXY=$http_proxy
export NO_PROXY=localhost,127.0.0.1
export RSYNC_PROXY=proxy.co.uk:80

export VISUAL=vim

export TOMCAT_HOME="~/opt/apache-tomcat-6.0.35"
export CATALINA_HOME="~/opt/apache-tomcat-6.0.35"

export MAVEN_OPTS="-Xmn1G -Xmx512m
-Djavax.net.ssl.trustStore=~/Documents/Certs/jssecacerts
-Djavax.net.ssl.keyStore=~/Documents/Certs/dev.p12
-Djavax.net.ssl.keyStorePassword=xxxx
-Djavax.net.ssl.keyStoreType=PKCS12
-Dhttp.proxyHost=proxy.co.uk -Dhttp.proxyPort=80
-Dhttps.proxyHost=proxy.co.uk -Dhttps.proxyPort=80
-Dhttp.nonProxyHosts=localhost
-Dclassworlds.conf=/usr/share/java/maven-2.2.1/bin/m2.conf
-Dmaven.home=/usr/share/java/maven-2.2.1
-Dmaven.repo.local=/Users/me/workspace/m2_repo/" 
export SBT_OPTS="$MAVEN_OPTS -Dsbt.ivy.home=$WORKSPACE/.ivy2/ -Divy.home=$WORKSPACE/.ivy2/"

export PATH=/usr/local/bin:~/opt/apache-jmeter-2.6/bin:~/opt/scala-2.9.2/bin:/opt/local/bin:/opt/local/sbin:$PATH

PS1="\n${debian_chroot:+($debian_chroot)}[\d \t] \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ "

ll() {
  ls -la "$@"
}

restartTomcat() {
  jps -lm | grep catalina | cut -d ' ' -f 1 | xargs kill -9
  currDir=$PWD
  cd ~/opt/apache-tomcat-6.0.35/bin/
  STUB_SERVER_HOST=http://localhost:4578 ./startup.sh
  cd $currDir
}

restartActivemq() { 
  currDir=$PWD
  cd ~/opt/apache-activemq-5.5.0/bin/
  ./activemq stop
  ./activemq start
  cd $currDir
}

sandbox() {
  ssh root@192.168.192.10 
}

tube() {
  curl -s http://www.tfl.gov.uk/tfl/livetravelnews/realtime/tube/default.html | grep -C 2 "class=\"status" | grep -o ">.*<" | sed 's/^.\(.*\).$/\1/' | sed 's/\&amp;/\&/g' | awk 'BEGIN{i=1}{line[i++]=$0}END{j=1; while (j<i) {print line[j] ":     \t" line[j+1]; j+=2}}'
}

location() {
  curl -s "http://freegeoip.net/xml/" | grep "<City>" | cut -c 11- | sed 's/.......$//'
}

weather() {
  geocode=`curl -s "http://www.ip2location.com/" | grep "chkWeather" | sed '3,3!d' | grep -o "(.*)" | cut -c2-9`
  curl -s "http://weather.yahooapis.com/forecastrss?p=$geocode&u=c" | grep -A 1 "Current Conditions" | sed  '1,1d' | sed 's/ C<.*/°C/'
}

tweet() {
  if [ "$#" = 1 ]
  then
    curl -s https://twitter.com/$1 | grep -A 1 -m 1 "<p class=\"js-tweet-text\">" | sed '2,2!d' | sed 's/<[^<>]*>//g' | sed 's/^[ ]*//g' | sed 's/\&quot;/\"/g' | sed "s/\&#39;/'/g" | sed "s/\&amp;/\&/g" | sed "s/\&nbsp;/ /g"
  else
    curl -s https://twitter.com/MikeSpelling | grep -A 1 -m 1 "<p class=\"js-tweet-text\">" | sed '2,2!d' | sed 's/<[^<>]*>//g' | sed 's/^[ ]*//g' | sed 's/\&quot;/\"/g' | sed "s/\&#39;/'/g" | sed "s/\&amp;/\&/g" | sed "s/\&nbsp;/ /g"
  fi
}

news_headline() {
  curl -s "http://www.bbc.co.uk/news/" | grep -A 1 "top-story-header" | sed 's/\&quot;/\"/g' | sed "s/\&#039;/'/g" | grep -o ">[^<>]*<" | sed 's/.*>//g' | sed 's/<.*//g'
}

news_summary() {
  curl -s "http://www.bbc.co.uk/news/" | grep -B 10 -m 1 "see-also" | sed 's/\&quot;/\"/g' | sed "s/\&#039;/'/g" | grep "<p>" | sed 's/^[^>]*>//g'
}

ip() {
  curl -s http://checkip.dyndns.org/ | sed 's/[a-zA-Z<>/ :]//g'
}

irc() {
  ps aux | grep "stunnel" | grep -v "grep" | awk '{print $2}' | xargs kill -9
  stunnel
  screen irssi
}

sslcurl() {
  curl -s --insecure --cert $WORKSPACE/certs/cert.pem "$@"
}

proxy_on() {
  dir=$PWD
  cp ~/.bash_profile_proxyon ~/.bash_profile
  cp ~/.subversion/servers_proxyon ~/.subversion/servers
  cp ~/.gitconfig_proxyon ~/.gitconfig
  cp ~/.ssh/config_proxyon ~/.ssh/config
  cp /usr/local/etc/stunnel/stunnel_proxyon.conf /usr/local/etc/stunnel/stunnel.conf
  source ~/.bash_profile
  cd $dir
}

proxy_off() {
  dir=$PWD
  cp ~/.bash_profile_proxyoff ~/.bash_profile
  cp ~/.subversion/servers_proxyoff ~/.subversion/servers
  cp ~/.gitconfig_proxyoff ~/.gitconfig
  cp ~/.ssh/config_proxyoff ~/.ssh/config
  cp /usr/local/etc/stunnel/stunnel_proxyoff.conf /usr/local/etc/stunnel/stunnel.conf
  source ~/.bash_profile
  cd $dir
}

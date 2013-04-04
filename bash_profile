cd ~/workspace

[[ -s "/Users/****/.rvm/scripts/rvm" ]] && source "/Users/****/.rvm/scripts/rvm"  # Load RVM

export WORKSPACE=~/workspace

export http_proxy=www-cache.proxy:80
export HTTP_PROXY=www-cache.proxy:80
export https_proxy=www-cache.proxy:80
export HTTPS_PROXY=www-cache.proxy:80
export ftp_proxy=ftp-gw.proxy:21
export ALL_PROXY=$http_proxy
export NO_PROXY=localhost,127.0.0.1
export RSYNC_PROXY=www-cache.proxy:80

export VISUAL=vim

export TOMCAT_HOME="/Users/****/opt/apache-tomcat-6.0.35"
export CATALINA_HOME="/Users/****/opt/apache-tomcat-6.0.35"

export MAVEN_OPTS="-Xmn1G -Xmx512m
-Djavax.net.ssl.trustStore=/Users/****/workspace/certs/jssecacerts
-Djavax.net.ssl.keyStore=/Users/****/workspace/certs/cert.p12
-Djavax.net.ssl.keyStorePassword=******
-Djavax.net.ssl.keyStoreType=PKCS12
-Dhttp.proxyHost=www-cache.proxy -Dhttp.proxyPort=80
-Dhttps.proxyHost=www-cache.proxy -Dhttps.proxyPort=80
-Dhttp.nonProxyHosts=localhost|bbc.co.uk
-Dclassworlds.conf=/usr/share/java/maven/bin/m2.conf
-Dmaven.home=/usr/share/java/maven
-Dmaven.repo.local=/Users/****/workspace/m2_repo/" 
export SBT_OPTS="$MAVEN_OPTS -Dsbt.ivy.home=$WORKSPACE/.ivy2/ -Divy.home=$WORKSPACE/.ivy2/"

export BBC_PEM_KEY=$HOME/Documents/Certs/cert.pem
export BBC_PEM_CA=$HOME/Documents/Certs/ca.pem
export BBC_CA_CERT=$HOME/Documents/Certs/ca.pem

export PATH=/usr/local/mysql/bin:/usr/local/bin:/Users/****/opt/apache-jmeter-2.6/bin:/Users/****/opt/scala-2.9.2/bin:/opt/local/bin:/opt/local/sbin:$PATH

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

alias sandbox='ssh root@192.168.192.10'

alias ip='ifconfig en1 | grep inet | cut -d " " -f2'

alias ccurl='curl -s --insecure --cert $WORKSPACE/certs/cert.pem "$@"'

tube() {
  curl -s http://www.tfl.gov.uk/tfl/livetravelnews/realtime/tube/default.html | grep -C 2 "class=\"status" | grep -o ">.*<" | sed 's/^.\(.*\).$/\1/' | sed 's/\&amp;/\&/g' | awk 'BEGIN{i=1}{line[i++]=$0}END{j=1; while (j<i) {print line[j] ":     \t" line[j+1]; j+=2}}'
}

metro() {
  curl -s "http://www.metrolink.co.uk/Pages/default.aspx" | grep -m 1 "serviceHP" | grep -E -o ">[^<]+<" | sed 's/>//g' | sed 's/<//g'
}

location() {
  curl -s "http://freegeoip.net/xml/" | grep "<City>" | sed 's/<[^<]*>//g'
}

weather() {
  geocode=`curl -s "http://www.ip2location.com/" | grep "chkWeather" | sed '3,3!d' | grep -o "(.*)" | cut -c2-9`
  curl -s "http://weather.yahooapis.com/forecastrss?p=$geocode&u=c" | grep -A 1 "Current Conditions" | sed  '1,1d' | sed 's/ C<.*/°C/'
}

getweatherimage() {
  html=`curl -s "http://www.ip2location.com/" | grep "chkWeather" | sed '3,3!d'`  geocode=`echo $html | grep -o "(.*)" | cut -c2-9`  city=`echo $html | grep -o 'chkWeather">[^(]*(' | sed 's/^.*>//g' | sed 's/[ ]*($//g'`
  curl -s http://www.weather.com/weather/today/$city+$geocode:1:UK | grep -A 1 "wx-first" | grep "img[^>]*wx-weather-icon" | grep -o 'src="[^"]*"' | sed 's/src="//g' | sed 's/"$//g' | xargs curl -s -o /tmp/weather.png
}

tweet() {
  username="****"
  if [ "$#" = 1 ]
  then
    username=$1
  fi
  curl -s https://twitter.com/$username | grep -A 1 -m 1 "<p class=\"js-tweet-text\">" | sed 's/<[^<>]*>//g' | sed 's/^[ ]*//g' | sed 's/\&quot;/\"/g' | sed "s/\&#39;/'/g" | sed "s/\&amp;/\&/g" | sed "s/\&nbsp;/ /g"
}

news() {
  OPTIND=1
  OPTERR=0
  summary="n"
  numLines=1
  while getopts "tshn:" option; do
    case $option in
       t)
         talkback="y"
         ;;
       s)
         summary="y"
         ;;
       n)
         numLines=$OPTARG
         ;;
       h)
         echo "Usage: news_headline [switches]"
         echo -e "\t-t\tTalkback the news"
         echo -e "\t-s\tInclude news summary"
         echo -e "\t-n\tSpecify number of news items"
         echo -e "\t-h\tHelp"
         return
         ;;
       \?)
         echo "Invalid option" >&2
         news -h
         return
         ;;
    esac
  done

  if [ "$summary" == "y" ]
  then
    result=`curl -s http://feeds.bbci.co.uk/news/rss.xml | awk '{ printf "%s", $0 }' | grep -o '<item>.*</item>' | grep -E -o '<title>[^<]*|<description>[^<]*' | sed 's/<[^>]*>//g' | sed 'N;s/\n/ - /;' | head -$numLines | sed 's/^/ * /g'`
  else
    result=`curl -s http://feeds.bbci.co.uk/news/rss.xml | awk '{ printf "%s", $0 }' | grep -o '<item>.*</item>' | grep -o '<title>[^<]*' | sed 's/<title>/ * /g' | head -$numLines`
  fi
  echo "$result"
  
  if [ "$talkback" == "y" ]
  then
    say -v hysterical "$result"
  fi

  unset talkback
  unset summary
  unset numLines
}

proxy_off() {
  dir=$PWD
  cp ~/.bash_profile_proxyoff ~/.bash_profile
  cp ~/.subversion/servers_proxyoff ~/.subversion/servers
  cp ~/.gitconfig_proxyoff ~/.gitconfig
  cp ~/.ssh/config_proxyoff ~/.ssh/config
  cp /usr/local/etc/stunnel/stunnel_proxyoff.conf /usr/local/etc/stunnel/stunnel.conf
  source ~/.bash_profile
  ps aux | grep "stunnel" | grep -v "grep" | awk '{print $2}' | xargs kill -9
  stunnel
  cd $dir
}

# 1. Instalacja #
> Wszystkie przykłady wykonywane są pod systemem Ubuntu server 12.04 amd64

## 1.1. Przygotowujemy system ##

* Tworzymy użytkownika, pod którym aplikacja ma działać np. *ishi*
* Tworzymy katalog */app/* z prawami zapisu dla użytkownika *ishi*
* Instalujemy w systemie niezbędne narzędzia

		$ sudo apt-get install git gcc make build-essential zlib1g-dev libssl-dev libreadline-gplv2-dev libxml2-dev libxslt-dev libsqlite3-dev librrd-dev

## 1.2. Instalujemy Ruby On Rails ##

* Instalujemy [rbenv wedle instrukcji](https://github.com/sstephenson/rbenv#section_2) dla użytkownika, pod którym będzie działać aplikacja 
* Instalujemy [ruby-build](https://github.com/sstephenson/ruby-build) jako plugin dla rbenv
* Mając zainstalowanego managere wersji rubiego instalujemy samego rubiego

		$ CONFIGURE_OPTS='--enable-shared' rbenv install 1.9.2-p290
		$ rbenv rehash
		$ rbenv global 1.9.2-p290

* Instalujemy Ruby On Rails

		$ gem install rails


## 1.3. Instalujemy interfejs Router Managera ##

* Klonujemy repozytorium z kodem aplikacji do katalogu */app/*

		$ git clone git://github.com/ishi/router-monitor.git /app

* Budujemy aplikację rails

		$ cd /app/www
		$ bundle
		$ rake db:migrate

* Ustawiamy użytkownika, jako który ma dzałać aplikacja. Kopiujemy plik /app/www/init_env.example jako /app/www/init_env, edytujemy i ustawiamy zmienną ROUTER_USER.

		$ vim /app/www/init_env

* Podpinamy skrypty startowe pod upstarta i uruchamiamy usługę

		$ sudo ln /app/www/lib/init/router-* /etc/init/
		$ sudo initctl reload-configuration
		$ sudo start router-cron

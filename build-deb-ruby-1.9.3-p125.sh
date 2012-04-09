#!/bin/sh

version=1.9.3
patch=p125
rubyversion=$version-$patch
rubysrc=ruby-$rubyversion.tar.bz2
checksum=702529a7f8417ed79f628b77d8061aa5
destdir=/tmp/install-$rubyversion

sudo apt-get -y install libssl-dev

if [ ! -f yaml-0.1.4.tar.gz ]; then
  wget -q http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz
fi

tar xzvf yaml-0.1.4.tar.gz
cd yaml-0.1.4
./configure --prefix=/usr && make && make install DESTDIR=$destdir
cd ..

if [ ! -f $rubysrc ]; then
  wget -q ftp://ftp.ruby-lang.org/pub/ruby/1.9/$rubysrc
fi

if [ "$(md5sum $rubysrc | cut -b1-32)" != "$checksum" ]; then
  echo "Checksum mismatch!"
  exit 1
fi

echo "Unpacking $rubysrc"
tar -jxf $rubysrc
cd ruby-$rubyversion
./configure --prefix=/usr --disable-install-doc --with-opt-dir=/tmp/libyaml/usr && make && make install DESTDIR=$destdir

cd ..
gem list -i fpm || sudo gem install fpm
fpm -s dir -t deb -n ruby$version -v $rubyversion -C $destdir \
  -p ruby-VERSION_ARCH.deb -d "libstdc++6 (>= 4.4.3)" \
  -d "libc6 (>= 2.6)" -d "libffi5 (>= 3.0.4)" -d "libgdbm3 (>= 1.8.3)" \
  -d "libncurses5 (>= 5.7)" -d "libreadline6 (>= 6.1)" \
  -d "libssl0.9.8 (>= 0.9.8)" -d "zlib1g (>= 1:1.2.2)" \
  usr/bin usr/lib usr/share/man usr/include

rm -r $destdir

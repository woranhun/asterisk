FROM ubuntu:16.04
#SSHServer
RUN apt-get update && \
	apt-get install openssh-server -y
RUN mkdir /var/run/sshd && \
	echo 'root:umszki123!' | chpasswd && \
	sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
	sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
#Asterisk
RUN apt-get update&&apt-get install build-essential wget libssl-dev libncurses5-dev libnewt-dev libxml2-dev linux-headers-$(uname -r) libsqlite3-dev uuid-dev git subversion git  -y
RUN cd /usr/src && \
	 wget downloads.asterisk.org/pub/telephony/asterisk/asterisk-13-current.tar.gz && \
	 tar zxvf asterisk-13-current.tar.gz && \
	 rm asterisk*.tar.gz
RUN cd /usr/src/asterisk-13* && \
	git clone https://github.com/asterisk/pjproject.git && \
	cd pjproject && \
	./configure --prefix=/usr --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr CFLAGS='-O2 -DNDEBUG' && \
	make dep && \
	make&&make install && \
	ldconfig && \
	ldconfig -p |grep pj
RUN cd /usr/src/asterisk* && \
	 contrib/scripts/get_mp3_source.sh  && \
	 printf 'y\n36\n' | contrib/scripts/install_prereq install
RUN ./configure && make menuselect && make && make install && \
	make samples && \
	make config && \
	ldconfig && \
	/etc/init.d/asterisk start

#asterisk ports: 5060,
EXPOSE 22 80 5060
CMD ["/usr/sbin/sshd", "-D"]

FROM stilliard/pure-ftpd

RUN echo \
    'nihmsftpuser:$6$x0HwRJld$xpRkxTjkstqg5.piEkUGcKyQGamvErjfNQKJiQZwdc18rSx/b.61u1TS9DF3ClMgrS7n3jXCALAq.v4CwXxGw.:500:101::/home/ftpusers/nihmsftpuser/./::::::1000:::::::' \
    > /etc/pureftpd.passwd && \
    echo 'yes' > /etc/pure-ftpd/conf/DontResolve && \
    echo 'yes' > /etc/pure-ftpd/conf/VerboseLog && \
    pure-pw mkdb /etc/pure-ftpd/pureftpd.pdb -f /etc/pureftpd.passwd

EXPOSE 21

ADD entrypoint.sh /

RUN chmod 550 /entrypoint.sh

ENTRYPOINT /entrypoint.sh -d -d -c 50 -C 10 -H -l puredb:/etc/pure-ftpd/pureftpd.pdb -E -j -R -p 30000:30100
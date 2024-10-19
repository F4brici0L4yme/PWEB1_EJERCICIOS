FROM bitnami/minideb

ENV DEBIAN_FRONTEND="noninteractive"

# Actualizar e instalar dependencias
RUN apt-get update && \
    apt-get install -y apache2 perl openssh-server vim bash locales tree libcgi-pm-perl dos2unix && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configurar locales
RUN echo -e 'LANG=es_PE.UTF-8\nLC_ALL=es_PE.UTF-8' > /etc/default/locale && \
    sed -i 's/^# *\(es_PE.UTF-8\)/\1/' /etc/locale.gen && \
    /sbin/locale-gen es_PE.UTF-8

# Crear usuario y directorios
RUN mkdir -p /home/pweb && \
    useradd pweb -m && echo "pweb:12345678" | chpasswd && \
    echo "root:12345678" | chpasswd && \
    chown pweb:www-data /usr/lib/cgi-bin/ && \
    chown pweb:www-data /var/www/html/ && \
    chmod 750 /usr/lib/cgi-bin/ && \
    chmod 750 /var/www/html/ 

# Configurar bash
RUN echo "export LC_ALL=es_PE.UTF-8" >> /home/pweb/.bashrc && \
    echo "export LANG=es_PE.UTF-8" >> /home/pweb/.bashrc && \
    echo "export LANGUAGE=es_PE.UTF-8" >> /home/pweb/.bashrc

# Crear enlaces simbólicos
RUN ln -s /usr/lib/cgi-bin /home/pweb/cgi-bin && \
    ln -s /var/www/html/ /home/pweb/html && \
    ln -s /home/pweb /usr/lib/cgi-bin/toHOME && \
    ln -s /home/pweb /var/www/html/toHOME

# Copiar y convertir scripts y archivos HTML
COPY ./cgi-bin/* /usr/lib/cgi-bin
RUN dos2unix /usr/lib/cgi-bin/Ejercicio2.pl && \
    chmod +x /usr/lib/cgi-bin/Ejercicio2.pl

COPY ./html /var/www/html

# Configurar Apache para CGI
RUN echo '<VirtualHost *:80>\n\
    ServerAdmin webmaster@localhost\n\
    DocumentRoot /var/www/html\n\
    ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/\n\
    <Directory "/usr/lib/cgi-bin">\n\
        AllowOverride None\n\
        Options +ExecCGI\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Habilitar el módulo CGI
RUN a2enmod cgid

# Configurar SSH
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Exponer puertos
EXPOSE 80
EXPOSE 22

# Comando para iniciar los servicios
CMD ["bash", "-c", "service ssh start && apachectl -D FOREGROUND"]
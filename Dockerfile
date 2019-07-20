FROM kevinplantier/s2i-php-container:latest

USER 0

EXPOSE 9998

ENV TIKA_VERSION 1.21
ENV TIKA_SERVER_URL https://www.apache.org/dist/tika/tika-server-$TIKA_VERSION.jar

RUN	yum install -y \
        java-1.8.0-openjdk \
	gnupg curl gdal \ 
	&& yum-config-manager --add-repo https://download.opensuse.org/repositories/home:/Alexander_Pozdnyakov/CentOS_7/ \
        && rpm --import https://build.opensuse.org/projects/home:Alexander_Pozdnyakov/public_key \
        && yum update -y \
        && yum install tesseract -y \ 
        && yum install tesseract-langpack-eng \ 
	tesseract-langpack-ita tesseract-langpack-fra tesseract-langpack-spa tesseract-langpack-deu -y \
	&& curl -sSL https://people.apache.org/keys/group/tika.asc -o /tmp/tika.asc \
	&& gpg --import /tmp/tika.asc \
	&& curl -sSL "$TIKA_SERVER_URL.asc" -o /tmp/tika-server-${TIKA_VERSION}.jar.asc \
	&& NEAREST_TIKA_SERVER_URL=$(curl -sSL http://www.apache.org/dyn/closer.cgi/${TIKA_SERVER_URL#https://www.apache.org/dist/}\?asjson\=1 \
		| awk '/"path_info": / { pi=$2; }; /"preferred":/ { pref=$2; }; END { print pref " " pi; };' \
		| sed -r -e 's/^"//; s/",$//; s/" "//') \
	&& echo "Nearest mirror: $NEAREST_TIKA_SERVER_URL" \
	&& curl -sSL "$NEAREST_TIKA_SERVER_URL" -o /tika-server-${TIKA_VERSION}.jar \
	&& yum clean all -y && rm -rf /var/lib/apt/lists/* 

ADD usr/share/container-scripts/php/pre-start/60-tika-server-start.sh /usr/share/container-scripts/php/pre-start/60-tika-server-start.sh

# Reset permissions of filesystem to default values
RUN rpm-file-permissions

USER 1001

FROM openjdk:11-slim
ENV GRADLE_VERSION=6.6.1
WORKDIR /app

# Environment variable below are not for overridding
ENV GRADLE_HOME=/opt/gradle/${GRADLE_VERSION}

# Install build tools
RUN apt update && apt install git wget unzip
## Get gradle
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && unzip -d /opt/gradle gradle-*.zip
RUN export PATH=${GRADLE_HOME}/bin:${PATH}
## Verify install
RUN gradle -v

# Fetch and build mirai-console-loader
RUN git clone https://github.com/iTXTech/mirai-console-loader.git \
	&& cd mirai-console-loader \
	&& gradle build \
	&& cp build/libs/mirai-console-loader-$(cat build.gradle | grep -E "version\ '[^']+'" | awk '{ print $2 }' | sed "s#'##g").jar ./mcl.jar \
	&& chmod +x ./mcl
# Run the thing
ENTRYPOINT [ "mirai-console-loader/mcl" ]


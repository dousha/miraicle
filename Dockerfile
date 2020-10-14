FROM openjdk:11-slim
ENV GRADLE_VERSION=6.6.1
WORKDIR /app

# Environment variable below are not for overridding
ENV GRADLE_HOME=/opt/gradle/gradle-${GRADLE_VERSION}
ENV PATH="${GRADLE_HOME}/bin:${PATH}"

# Install build tools
RUN apt update && apt --yes install git wget unzip
## Get gradle
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && unzip -d /opt/gradle gradle-*.zip
## Verify install
RUN gradle -v

# Fetch and build mirai-console-loader
RUN git clone https://github.com/iTXTech/mirai-console-loader.git
WORKDIR /app/mirai-console-loader
RUN gradle build \
	&& cp build/libs/mirai-console-loader-$(cat build.gradle | grep -E "version\ '[^']+'" | awk '{ print $2 }' | sed "s#'##g").jar ./mcl.jar \
	&& chmod +x ./mcl
# Run the thing
ENTRYPOINT [ "./mcl" ]


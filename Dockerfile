# -- Stage 0: Loader
FROM gradle:6.7.0-jdk11 AS loader
WORKDIR /app

# Fetch and build mirai-console-loader
RUN git clone https://github.com/iTXTech/mirai-console-loader.git
WORKDIR /app/mirai-console-loader
RUN gradle build \
	&& cp build/libs/mirai-console-loader-$(cat build.gradle | grep -E "version\ '[^']+'" | awk '{ print $2 }' | sed "s#'##g").jar ./mcl.jar \
	&& chmod +x ./mcl


# -- Stage 1: HTTP Plugin API
FROM gradle:6.7.0-jdk11 AS httpPlugin
WORKDIR /app

# Fetch and build mirai-api-http
#RUN git clone https://github.com/project-mirai/mirai-api-http.git
#WORKDIR /app/mirai-api-http
#RUN ./gradlew shadow \
#	&& cp mirai-api-http/build/libs/*.jar /app/mirai-api-http.jar
# ^ XXX: let's hope there is only one artifact...
# Or just fetch the artifact straight from project releases
COPY downloadHttpPlugin.sh .
RUN chmod +x ./downloadHttpPlugin.sh && ./downloadHttpPlugin.sh

# -- Stage 2: Install dependencies and Shipment
FROM openjdk:11-slim AS production
WORKDIR /app

# Copy previously built mirai-console-loader
COPY --from=loader /app/mirai-console-loader /app/mcl/
# Copy previously built mirai-api-http
COPY --from=httpPlugin /app/mirai-api-http.jar /app/mcl/plugins/
# Copy configuration file
COPY httpApiSettings.yml /app/mcl/config/MiraiApiHttp/setting.yml
# Copy package.json-like config.json
COPY config.json /app/mcl/config.json
# Expose ports
EXPOSE 8080
# The app and the scripts assume the current working directory
WORKDIR /app/mcl
COPY start.sh .
RUN chmod +x start.sh
# Preconfigure
RUN java -jar mcl.jar -u -z
# Run the thing
ENTRYPOINT [ "./start.sh" ]
CMD [ "-u" ]


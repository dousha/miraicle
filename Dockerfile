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
RUN git clone https://github.com/project-mirai/mirai-api-http.git
WORKDIR /app/mirai-api-http
RUN ./gradlew shadow \
	&& cp build/libs/*.jar ./mirai-api-http.jar
# ^ XXX: let's hope there is only one artifact...

# -- Stage 2: Shipment
FROM openjdk:11-slim AS production
WORKDIR /app

# Copy previously built mirai-console-loader
COPY --from=loader /app/mirai-console-loader /app/mcl/
# Copy previously built mirai-api-http
COPY --from=httpPlugin /app/mirai-api-http.jar /app/mcl/plugins/
# Copy configuration file
COPY httpApiSettings.yml /app/mcl/config/MiraiApiHttp/settings.yml
# Expose ports
EXPOSE 8080
# I guess the app assumes the current working directory
WORKDIR /app/mcl
# Run the thing
ENTRYPOINT [ "./mcl" ]

FROM gradle:6.7.0-jdk11 AS loader
WORKDIR /app

# Fetch and build mirai-console-loader
RUN git clone https://github.com/iTXTech/mirai-console-loader.git
WORKDIR /app/mirai-console-loader
RUN gradle build \
	&& cp build/libs/mirai-console-loader-$(cat build.gradle | grep -E "version\ '[^']+'" | awk '{ print $2 }' | sed "s#'##g").jar ./mcl.jar \
	&& chmod +x ./mcl
# Run the thing
ENTRYPOINT [ "./mcl" ]


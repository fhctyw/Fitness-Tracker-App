FROM openjdk:8-jdk AS build

ENV ANDROID_SDK_ROOT=/sdk
RUN mkdir -p $ANDROID_SDK_ROOT && \
    apt-get update && \
    apt-get install -y wget unzip dos2unix && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip -d $ANDROID_SDK_ROOT && \
    mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    mv $ANDROID_SDK_ROOT/tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    rm cmdline-tools.zip

RUN yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --licenses && \
    $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-29" "build-tools;30.0.2"

WORKDIR /app

COPY . .

RUN dos2unix ./gradlew

RUN chmod +x ./gradlew

RUN rm -f app/src/main/res/drawable/yoga.png

RUN ./gradlew build --no-daemon --stacktrace

# Створюємо легший образ для запуску
FROM openjdk:8-jre-slim

COPY --from=build /app/app/build/outputs/apk/debug/app-debug.apk /app/app-debug.apk

CMD ["echo", "Android APK is built and available at /app/app-debug.apk"]

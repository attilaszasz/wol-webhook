#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
# Docker automatically provides TARGETARCH
ARG TARGETARCH

# Install dependencies for AOT publishing on Alpine (musl libc)
RUN apk update \
    && apk add --no-cache clang build-base zlib-dev

# Convert TARGETARCH to .NET Runtime Identifier
RUN echo $TARGETARCH | sed 's/amd64/x64/' > /tmp/rid_arch

ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["webhook/webhook.csproj", "webhook/"]
RUN dotnet restore "./webhook/webhook.csproj" -r "linux-musl-$(cat /tmp/rid_arch)"
COPY . .
WORKDIR "/src/webhook"

# Publish directly (removes redundant build step) with extreme AOT size optimization flags
RUN dotnet publish "./webhook.csproj" -c $BUILD_CONFIGURATION -o /app/publish \
    -r "linux-musl-$(cat /tmp/rid_arch)" \
    --self-contained \
    /p:PublishAot=true \
    /p:OptimizationPreference=Size \
    /p:StackTraceSupport=false \
    /p:EventSourceSupport=false \
    /p:StripSymbols=true

FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-alpine AS final
USER app
WORKDIR /app
ENV ASPNETCORE_HTTP_PORTS=12563
EXPOSE 12563
COPY --from=build /app/publish .
ENTRYPOINT ["./webhook"]
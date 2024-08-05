#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:8.0-noble-chiseled AS base
USER app
WORKDIR /app
EXPOSE 12563

FROM mcr.microsoft.com/dotnet/sdk:8.0-noble AS build
# Install clang/zlib1g-dev dependencies for publishing to native
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    clang zlib1g-dev
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["webhook/webhook.csproj", "webhook/"]
RUN dotnet restore "./webhook/webhook.csproj"
COPY . .
WORKDIR "/src/webhook"
RUN dotnet build "./webhook.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./webhook.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=true

FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-noble-chiseled AS final
WORKDIR /app
ENV ASPNETCORE_HTTP_PORTS=12563
EXPOSE 12563
COPY --from=publish /app/publish .
ENTRYPOINT ["./webhook"]
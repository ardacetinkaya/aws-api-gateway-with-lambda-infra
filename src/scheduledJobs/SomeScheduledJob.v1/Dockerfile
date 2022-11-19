FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base
WORKDIR /app

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["SomeScheduledJob.v1.csproj", "SomeScheduledJob.v1/"]
WORKDIR "/src/SomeScheduledJob.v1"
RUN dotnet restore "SomeScheduledJob.v1.csproj"
COPY . .
RUN dotnet build "SomeScheduledJob.v1.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "SomeScheduledJob.v1.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SomeScheduledJob.v1.dll"]

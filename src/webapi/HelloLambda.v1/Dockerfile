FROM mcr.microsoft.com/dotnet/aspnet:6.0-focal AS base
WORKDIR /app
EXPOSE 5090

ENV ASPNETCORE_URLS=http://+:5090

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:6.0-focal AS build
WORKDIR /src
COPY ["src/webapi/HelloLambda.v1/HelloLambda.v1.csproj", "src/webapi/HelloLambda.v1/"]
RUN dotnet restore "src/webapi/HelloLambda.v1/HelloLambda.v1.csproj"
COPY . .
WORKDIR "/src/src/webapi/HelloLambda.v1"
RUN dotnet build "HelloLambda.v1.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "HelloLambda.v1.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "HelloLambda.dll"]

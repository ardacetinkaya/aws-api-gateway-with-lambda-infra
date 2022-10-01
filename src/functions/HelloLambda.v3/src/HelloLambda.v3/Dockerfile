FROM public.ecr.aws/lambda/dotnet:6 AS base
WORKDIR /var/task


FROM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim AS build
WORKDIR /src
COPY ["HelloLambda.v3.csproj", "HelloLambda.v3/"]
WORKDIR "/src/HelloLambda.v3"
RUN dotnet restore "HelloLambda.v3.csproj" --runtime linux-x64
COPY . .
RUN dotnet build "HelloLambda.v3.csproj" -c Release -o /app/build --runtime linux-x64

FROM build AS publish
RUN dotnet publish "HelloLambda.v3.csproj" -c Release -o /app/publish --self-contained false --runtime linux-x64

FROM base AS final
WORKDIR /var/task
COPY --from=publish /app/publish .
CMD [ "HelloLambda.v3::HelloLambda.v3.Functions::Get"]
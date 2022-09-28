FROM public.ecr.aws/lambda/dotnet:6 AS base
WORKDIR /var/task


FROM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim AS build
WORKDIR /src
COPY ["HelloLambda.v2.csproj", "HelloLambda.v2/"]
WORKDIR "/src/HelloLambda.v2"
RUN dotnet restore "HelloLambda.v2.csproj" --runtime linux-x64
COPY . .
RUN dotnet build "HelloLambda.v2.csproj" -c Release -o /app/build --runtime linux-x64

FROM build AS publish
RUN dotnet publish "HelloLambda.v2.csproj" -c Release -o /app/publish --runtime linux-x64

FROM base AS final
WORKDIR /var/task
COPY --from=publish /app/publish .
CMD [ "HelloLambda.v2::HelloLambda.v2.LambdaEntryPoint::FunctionHandlerAsync"]

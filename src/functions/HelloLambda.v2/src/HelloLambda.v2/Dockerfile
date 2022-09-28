FROM public.ecr.aws/lambda/dotnet:6 AS base
WORKDIR /var/task


FROM mcr.microsoft.com/dotnet/sdk:6.0-focal AS build
WORKDIR /src
COPY ["HelloLambda.v2.csproj", "HelloLambda.v2/"]
WORKDIR "/src/HelloLambda.v2"
COPY . .
RUN dotnet build "HelloLambda.v2.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "HelloLambda.v2.csproj" -c Release -o /app/publish /p:UseAppHost=false --no-restore

FROM base AS final
WORKDIR /var/task
COPY --from=publish /app/publish .
CMD [ "HelloLambda.v2::HelloLambda.v2.LambdaEntryPoint::FunctionHandlerAsync"]

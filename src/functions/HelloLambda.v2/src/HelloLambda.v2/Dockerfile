FROM public.ecr.aws/lambda/dotnet:6 AS base
WORKDIR /var/task


FROM mcr.microsoft.com/dotnet/sdk:6.0-focal AS build
WORKDIR /src
COPY ["src/functions/HelloLambda.v2/src/HelloLambda.v2/HelloLambda.v2.csproj", "src/functions/HelloLambda.v2/src/HelloLambda.v2/"]
RUN dotnet restore "src/functions/HelloLambda.v2/src/HelloLambda.v2/HelloLambda.v2.csproj"
COPY . .
WORKDIR "/src/src/functions/HelloLambda.v2/src/HelloLambda.v2"
RUN dotnet build "HelloLambda.v2.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "HelloLambda.v2.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /var/task
COPY --from=publish /app/publish .
CMD [ "HelloLambda.v2::HelloLambda.v2.LambdaEntryPoint::FunctionHandlerAsync"]

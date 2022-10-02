FROM public.ecr.aws/lambda/dotnet:6 AS base
WORKDIR /var/task


FROM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim AS build
WORKDIR /src
COPY ["HelloLambda.v4.csproj", "HelloLambda.v4/"]
WORKDIR "/src/HelloLambda.v4"
RUN dotnet restore "HelloLambda.v4.csproj" --runtime linux-x64
COPY . .
RUN dotnet build "HelloLambda.v4.csproj" -c Release -o /app/build --runtime linux-x64

FROM build AS publish
RUN dotnet publish "HelloLambda.v4.csproj" -c Release -o /app/publish --self-contained false --runtime linux-x64

FROM base AS final
WORKDIR /var/task
COPY --from=publish /app/publish .
CMD [ "HelloLambda.v4::HelloLambda.v4.Function::FunctionHandler"]
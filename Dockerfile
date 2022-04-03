FROM mcr.microsoft.com/dotnet/core/runtime:2.2 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:2.1-alpine AS build
ENV BuildingDocker true
WORKDIR /src
COPY SmartHotel360.Website.csproj .
RUN dotnet restore
COPY . .
RUN dotnet build -c Release -o /webapp


FROM node:8.12.0-alpine as node
WORKDIR /src
COPY . .
WORKDIR /src/ClientApp
RUN npm install
RUN npm rebuild node-sass
RUN npm run build
RUN cp -r build/* /src/wwwroot

FROM build AS publish
WORKDIR /src/ClientApp
WORKDIR /src
RUN dotnet publish -c Release -o /webapp

FROM base AS final
WORKDIR /app
COPY --from=publish /webapp .
COPY --from=node /src/wwwroot ./wwwroot
ENTRYPOINT ["dotnet", "SmartHotel360.Website.dll"]

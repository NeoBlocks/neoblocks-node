# NeoBlocks Node
# https://github.com/NeoBlocks/neoblocks-node
# MIT License
# Copyright (c) 2020 NeoBlocks B.V.

FROM microsoft/dotnet:2.1-sdk

SHELL ["/bin/bash", "-c"]
WORKDIR /app
RUN apt update
RUN apt install -y libleveldb-dev patch
RUN rm /var/lib/apt/lists/* -fr

RUN mkdir /app/source
RUN mkdir /app/source/modules

# Add the project source files
ADD neo/neo /app/source/neo
ADD neo-node/neo-cli /app/source/neo-cli

# Add the module source files
ADD neo-modules/SimplePolicy /app/source/modules/SimplePolicy
ADD neoblocks/EventLogs /app/source/modules/EventLogs

# Patch the source files
WORKDIR /app/source
COPY ./neoblocks/neo.patch ./
RUN patch -p1 < ./neo.patch

# Build project neo-cli from source
WORKDIR /app/source/neo-cli
COPY ./neoblocks/neo-cli.csproj.diff ./
RUN patch -p1 < ./neo-cli.csproj.diff
RUN dotnet restore
RUN dotnet publish -c Release -f netcoreapp2.1 -o /app/

# Build the EventLogs plugin
WORKDIR /app/source/modules/EventLogs
RUN dotnet restore
RUN dotnet publish -c Release -f netstandard2.0 -o /app/Plugins/

# Build the SimplePolicy plugin
WORKDIR /app/source/modules/SimplePolicy
COPY ./neoblocks/SimplePolicy.csproj.diff ./
RUN patch -p1 < ./SimplePolicy.csproj.diff
RUN dotnet restore
RUN dotnet publish -c Release -f netstandard2.0 -o /app/Plugins/

WORKDIR /app

# Finish building the image
COPY ./neoblocks/config.json ./

EXPOSE 10332
EXPOSE 10333
EXPOSE 10334

ENV DEBIAN_FRONTEND noninteractive
ENV DOTNET_CLI_TELEMETRY_OPTOUT 1

CMD ["/usr/bin/dotnet", "/app/neo-cli.dll", "/rpc", "/log"]

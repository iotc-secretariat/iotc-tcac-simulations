FROM rocker/shiny:4.1.2

# Environment variables

ENV _R_SHLIB_STRIP_=true

WORKDIR /

# Installs R packages

RUN install2.r --error --skipinstalled \
    stringr \
    scales \
    data.table \
    openxlsx \
    dplyr \
    shiny \
    shinyjs \ 
    shinyWidgets \
    shinycssloaders \ 
    DT

# Copies the initialization scripts and shiny app sources in the container

RUN rm -rf /srv/shiny-server/*

COPY ./shiny /srv/shiny-server/tcac_simulation
COPY ./shiny/conf/shiny-server.conf /etc/shiny-server

RUN mkdir /srv/shiny-server/cfg

COPY ./scripts/01.configure_and_preprocess.R /srv/shiny-server/scripts
COPY ./cfg/CPC_CONFIGURATIONS.xlsx /srv/shiny-server/cfg
COPY ./cfg/HISTORICAL_CATCH_ESTIMATES.csv /srv/shiny-server/cfg

# Updates the R environment with all variables necessary to connect to the DB etc.

RUN echo SHINY_LOG_LEVEL=TRACE >> /home/shiny/.Renviron && \
    chown shiny.shiny /home/shiny/.Renviron

# Removes an unnecessary directory under the Shiny app folder
RUN rm -rf /srv/shiny-server/tcac_simulations/conf

# Continues configuring Shiny
RUN echo "shiny:pass" | chpasswd
RUN adduser shiny sudo

# User running the Shiny server
USER shiny

# TCP/IP Port
EXPOSE 3838

# Starts Shiny
CMD ["/usr/bin/shiny-server"]

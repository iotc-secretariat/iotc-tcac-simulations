FROM rocker/shiny:4.1.2

# Environment variables

ENV _R_SHLIB_STRIP_=true

WORKDIR /

# Installs all required R packages (and their dependencies)

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

# Copies the configuration, the initialization scripts and the Shiny app sources in the proper container folders

RUN rm -rf /srv/shiny-server/*

COPY ./shiny /srv/shiny-server/tcac_simulations
COPY ./shiny/conf/shiny-server.conf /etc/shiny-server

RUN mkdir /srv/shiny-server/cfg
RUN mkdir /srv/shiny-server/scripts

COPY ./scripts/01.configure_and_preprocess.R /srv/shiny-server/scripts

COPY ./cfg/CPC_CONFIGURATIONS.xlsx /srv/shiny-server/cfg
COPY ./cfg/HISTORICAL_CATCH_ESTIMATES.csv /srv/shiny-server/cfg

# To be able to download these files they need to be copied under the 'www' folder
COPY ./README.html /srv/shiny-server/tcac_simulations/www       
COPY ./cfg/CPC_CONFIGURATIONS.xlsx /srv/shiny-server/tcac_simulations/www        
COPY ./cfg/HISTORICAL_CATCH_ESTIMATES.csv /srv/shiny-server/tcac_simulations/www 

# Sets the Shiny log level to 'TRACE', stores the environment variable in .Renviron and copies that file under the 'shiny' user folder
RUN echo SHINY_LOG_LEVEL=TRACE >> /home/shiny/.Renviron && chown shiny.shiny /home/shiny/.Renviron

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

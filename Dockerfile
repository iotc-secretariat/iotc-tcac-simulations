FROM rocker/shiny:4.3.0

# Environment variables

ENV _R_SHLIB_STRIP_=true

WORKDIR /

# system libraries for LaTeX reporting & keyring
RUN apt-get update && apt-get install -y \
    sudo \
    vim \
    pandoc \
    pandoc-citeproc \
    texlive-xetex \
    texlive-base \
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-formats-extra \
    ghostscript
    
# Installs all required R packages (and their dependencies)
RUN install2.r --error --skipinstalled \
    pacman \
    remotes \
    stringr \
    scales \
    data.table \
    openxlsx \
    dplyr \
    shiny \
    shinyjs \ 
    shinyWidgets \
    shinycssloaders \ 
    DT \
    officer \
    officedown \
    kableExtra \
    knitr \
    rmarkdown

#RUN R -e "remotes::install_github('omegahat/RDCOMClient')"

# Copies the configuration, the initialization scripts and the Shiny app sources in the proper container folders

RUN rm -rf /srv/shiny-server/*

COPY ./initialisation /srv/shiny-server/initialisation
COPY ./shiny /srv/shiny-server/tcac_simulations
COPY ./shiny/conf/shiny-server.conf /etc/shiny-server

RUN mkdir /srv/shiny-server/cfg
RUN mkdir /srv/shiny-server/scripts

COPY ./scripts/00.core.R /srv/shiny-server/scripts
COPY ./scripts/01.cpc_input_data.R /srv/shiny-server/scripts
COPY ./scripts/02.catch_input_data.R /srv/shiny-server/scripts
COPY ./scripts/03.catch_computation_functions.R /srv/shiny-server/scripts
COPY ./scripts/04.allocation_computation.R /srv/shiny-server/scripts
COPY ./scripts/90.libraries.R /srv/shiny-server/scripts

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

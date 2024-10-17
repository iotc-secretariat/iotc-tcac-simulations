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
    
# general system libraries
RUN apt-get update && apt-get install -y \
    cmake \
    curl \
    default-jdk \
    fonts-roboto \
    hugo \
    less \
    libbz2-dev \
    libglpk-dev \
    libgmp3-dev \
    libfribidi-dev \
    libharfbuzz-dev \
    libhunspell-dev \
    libicu-dev \
    liblzma-dev \
    libmagick++-dev \
    libopenmpi-dev \
    libpcre2-dev \
    libssl-dev \
    libv8-dev \
    libxml2-dev \
    libxslt1-dev \
    libzmq3-dev \
    lsb-release \
    qpdf \
    texinfo \
    software-properties-common \
    vim \
    wget
    
# install R core package dependencies
RUN install2.r --error --skipinstalled --ncpus -1 httpuv
RUN R -e "install.packages(c('remotes','jsonlite','yaml'), repos='https://cran.r-project.org/')"

# Cleaning shiny-server dir
RUN rm -rf /srv/shiny-server/*

#copy shiny-server configuration
COPY ./conf/shiny-server.conf /etc/shiny-server

#copy shiny app
COPY . /srv/shiny-server/tcac_simulations

# install R app package dependencies
RUN R -e "source('./srv/shiny-server/tcac_simulations/install.R')"

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

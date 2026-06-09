FROM rocker/shiny:4.5.1

# Environment variables
ENV _R_SHLIB_STRIP_=true

WORKDIR /

# system libraries for LaTeX reporting & keyring
RUN apt-get update && apt-get install -y \
    sudo \
    vim \
    pandoc \
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
    libudunits2-dev \
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

#working directory
WORKDIR /srv/iotc-tcac-simulations

# Set environment variables for renv cache, see doc https://docs.docker.com/build/cache/backends/
ARG RENV_PATHS_ROOT

# Make a directory in the container
RUN mkdir -p ${RENV_PATHS_ROOT}

#copy renv configuration
RUN R -e "install.packages(c('renv'), repos='https://cran.r-project.org/')"
COPY renv.lock renv.lock
COPY .Rprofile  .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

# Set renv cache location: change default location of cache to project folder
# see documentation for Multi-stage builds => https://cran.r-project.org/web/packages/renv/vignettes/docker.html
RUN mkdir renv/.cache
ENV RENV_PATHS_CACHE=renv/.cache

# Restore the R environment
RUN R -e "renv::restore()"

#copy app
COPY . /srv/iotc-tcac-simulations
# To be able to download these files they need to be copied under the 'www' folder
COPY ./cfg/CPC_CONFIGURATIONS.xlsx /srv/iotc-tcac-simulations/www  
#etc dirs (for config)
RUN mkdir -p /etc/iotc-tcac-simulations/

EXPOSE 3838

CMD ["R", "-e shiny::runApp('/srv/iotc-tcac-simulations',port=3838,host='0.0.0.0')"]

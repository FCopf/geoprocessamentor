FROM rocker/binder:4.3.1
LABEL maintainer='Fabio Cop'
COPY --chown=${NB_USER} . ${HOME}
USER ${NB_USER}



RUN wget https://github.com/FCopf/geoprocessamentor/raw/master/DESCRIPTION && R -e "options(repos = list(CRAN = 'http://mran.revolutionanalytics.com/snapshot/2023-08-24/')); devtools::install_deps()"

RUN rm DESCRIPTION.1; exit 0

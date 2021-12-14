# this modifies a version from https://github.com/Enchufa2/cran2copr
# by Iñaki Ucar
# GPL-2.0

FROM registry.fedoraproject.org/fedora:35

RUN echo "install_weak_deps=False" >> /etc/dnf/dnf.conf \
    && dnf -y upgrade && dnf -y install R-core && dnf -y clean all

RUN dnf -y install 'dnf-command(copr)' \
    && dnf -y copr enable iucar/cran \
    && sed -ie '/nodocs/d' /etc/dnf/dnf.conf \
    && dnf -y install sudo R-CoprManager && dnf -y clean all \
    && echo "options(CoprManager.sudo=TRUE)" > \
        /usr/lib64/R/etc/Rprofile.site.d/51-CoprManager-sudo.site \
    && echo "options(repos='https://cloud.r-project.org')" > \
        /usr/lib64/R/etc/Rprofile.site.d/00-repos.site

RUN dnf -y install R-CRAN-rmarkdown R-CRAN-rticles R-CRAN-data.table R-CRAN-grates R-CRAN-remotes R-CRAN-ggplot2 && dnf -y clean all

RUN dnf -y install texlive-endfloat texlive-todonotes texlive-lastpage texlive-mathdesign texlive-preprint texlive-forarray && dnf -y clean all

RUN mkdir /home/demopw
WORKDIR /home/demopw

LABEL org.opencontainers.image.source="https://github.com/timtaylor/demopw"

CMD ["bash"]

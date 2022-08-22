FROM ubuntu:20.04
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends apt-utils software-properties-common wget \
    && apt-get install -y build-essential python3 python3-distutils \
    && wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py \
    && python3 get-pip.py --trusted-host pypi.org --trusted-host files.pythonhosted.org
#RUN apt-get install python3.6 python-pip
#RUN python -m pip install pip --upgrade
#RUN python -m pip install wheel
#RUN apt-get install -y python3-numpy

ENV DEBIAN_FRONTEND noninteractive \
    && DBCONF_NONINTERACTIVE_SEEN true
# Installing pandas will also install scipy and numpy. However the independent commands are similar i.e python3-numpy, python3-scipy
# To install sklearn follow the same pattern i.e python3-sklearn
RUN apt-get install -y python3-pandas \
    && echo "Asia/Kolkata" > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata
RUN mkdir /app
WORKDIR /app
COPY requirements.txt .
COPY main.py main.py
ENV BATCH_FILES_PATH="data/"
ENTRYPOINT ["python3", "./main.py"]
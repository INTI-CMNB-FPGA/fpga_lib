from debian:buster-slim

RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    make gcc g++ git bash-completion doxygen graphviz && \
    apt-get autoremove -y && apt-get clean

RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    python python-dev python-setuptools python-pip python-wheel && \
    apt-get autoremove -y && apt-get clean

RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    ghdl-gcc gnat iverilog gtkwave && \
    apt-get autoremove -y && apt-get clean

RUN pip install cocotb

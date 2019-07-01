from debian:buster-slim

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y make gcc g++ ghdl-gcc gnat iverilog gtkwave git bash-completion
RUN apt-get autoremove -y
RUN apt-get clean
